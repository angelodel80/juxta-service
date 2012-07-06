
CREATE TABLE IF NOT EXISTS juxta_workspace (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    PRIMARY KEY (id),
    UNIQUE (name),
    INDEX(name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_source (
    id BIGINT NOT NULL AUTO_INCREMENT,
	name VARCHAR(255) NOT NULL,
	content_id BIGINT NOT NULL,
	workspace_id BIGINT NOT NULL default 1,
	created DATETIME not null,
    updated DATETIME,
	PRIMARY KEY (id),
    FOREIGN KEY (workspace_id) REFERENCES juxta_workspace (id) ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES text_content (id),
    UNIQUE INDEX(name, workspace_id),
	INDEX (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_qname_filter (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    workspace_id BIGINT NOT NULL default 1,
    PRIMARY KEY (id),
    FOREIGN KEY (workspace_id) REFERENCES juxta_workspace (id) ON DELETE CASCADE,
    UNIQUE INDEX(name, workspace_id),
    INDEX(name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_qname_filter_member (
    id BIGINT NOT NULL AUTO_INCREMENT,
    filter_id BIGINT NOT NULL,
    qname_id BIGINT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (filter_id) REFERENCES juxta_qname_filter (id) ON DELETE CASCADE,
    FOREIGN KEY (qname_id) REFERENCES text_qname (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_xslt (
    id BIGINT NOT NULL AUTO_INCREMENT,
    workspace_id BIGINT NOT NULL default 1,
    name VARCHAR(255) NOT NULL,
    xslt text not null,
    default_namespace VARCHAR(255),
    UNIQUE INDEX(name, workspace_id),
    PRIMARY KEY (id),
    FOREIGN KEY (workspace_id) REFERENCES juxta_workspace (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_witness (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    source_id BIGINT NOT NULL,
    xslt_id BIGINT,
    text_id BIGINT NOT NULL,
    fragment_start BIGINT NOT NULL,
    fragment_end BIGINT NOT NULL,
    workspace_id BIGINT NOT NULL default 1,
    created DATETIME not null,
    updated DATETIME,
    PRIMARY KEY(id),
    FOREIGN KEY (source_id) REFERENCES juxta_source (id),
    FOREIGN KEY (xslt_id) REFERENCES juxta_xslt (id),
    FOREIGN KEY (text_id) REFERENCES text_content (id),
    FOREIGN KEY (workspace_id) REFERENCES juxta_workspace (id) ON DELETE CASCADE,
    UNIQUE INDEX(name, workspace_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_revision (
    id BIGINT NOT NULL AUTO_INCREMENT,
    witness_id BIGINT NOT NULL,
    revision_type ENUM('ADD','DELETE') not null,
    start BIGINT NOT NULL,
    end BIGINT NOT NULL,
    content TEXT,
    is_included BOOL NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (witness_id) REFERENCES juxta_witness (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_comparison_set (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
	workspace_id BIGINT NOT NULL default 1,
	status ENUM('NOT_COLLATED','COLLATING','COLLATED','ERROR') not null default 'NOT_COLLATED',
    created DATETIME not null,
    updated DATETIME,
    PRIMARY KEY (id),
    FOREIGN KEY (workspace_id) REFERENCES juxta_workspace (id) ON DELETE CASCADE,
	UNIQUE INDEX(name, workspace_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_collation_cache (
    id BIGINT NOT NULL AUTO_INCREMENT,
    set_id BIGINT NOT NULL,
    witness_list VARCHAR(255) NOT NULL,
    data_type enum('HEATMAP', "SIDEBYSIDE", "HISTOGRAM") not null,
    data LONGTEXT,
    PRIMARY KEY (id),
    UNIQUE (set_id, witness_list, data_type),
    FOREIGN KEY (set_id) REFERENCES juxta_comparison_set (id)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_collator_config (
    id BIGINT NOT NULL AUTO_INCREMENT,
    set_id BIGINT NOT NULL,
    filter_whitespace BOOL NOT NULL DEFAULT 1,
    filter_punctuation BOOL NOT NULL DEFAULT 1,
    filter_case BOOL NOT NULL DEFAULT 1,
    hyphenation_filter enum('INCLUDE_ALL','FILTER_LINEBREAK','FILTER_ALL') not null default 'INCLUDE_ALL',
    PRIMARY KEY (id),
    FOREIGN KEY (set_id) REFERENCES juxta_comparison_set (id)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_comparison_set_member (
    set_id BIGINT NOT NULL,
    witness_id BIGINT NOT NULL,
	UNIQUE (set_id, witness_id),
    FOREIGN KEY (set_id) REFERENCES juxta_comparison_set (id) ON DELETE CASCADE,
    FOREIGN KEY (witness_id) REFERENCES juxta_witness (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_note (
    id BIGINT NOT NULL AUTO_INCREMENT,
    witness_id BIGINT NOT NULL,
    anchor_start BIGINT NOT NULL,
    anchor_end BIGINT NOT NULL,
    note_type VARCHAR(255),
    target_xml_id VARCHAR(255),
    content TEXT,
    PRIMARY KEY (id),
    FOREIGN KEY (witness_id) REFERENCES juxta_witness (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS juxta_page_break (
    id BIGINT NOT NULL AUTO_INCREMENT,
    witness_id BIGINT NOT NULL,
    offset BIGINT NOT NULL,
    label TEXT,
    PRIMARY KEY (id),
    FOREIGN KEY (witness_id) REFERENCES juxta_witness (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS juxta_alignment (
    id BIGINT NOT NULL AUTO_INCREMENT,
    set_id  BIGINT NOT NULL,
    qname_id  BIGINT NOT NULL,
    group_num INT NOT NULL default 0,
    manual BOOL not null default 0,
    edit_distance INT NOT NULL DEFAULT -1,
    annotation_a_id BIGINT NOT NULL,
    annotation_b_id BIGINT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (set_id) REFERENCES juxta_comparison_set (id) ON DELETE CASCADE,
    FOREIGN KEY (annotation_a_id) REFERENCES text_annotation (id) ON DELETE CASCADE,
    FOREIGN KEY (annotation_a_id) REFERENCES text_annotation (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE text_annotation_link_data;
DROP TABLE text_annotation_link_target;
DROP TABLE text_annotation_link;
