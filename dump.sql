--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.9
-- Dumped by pg_dump version 10.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;
SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE account (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


-- ALTER TABLEaccount OWNER TO openchs;

--
-- Name: account_admin; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE account_admin (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    account_id integer NOT NULL,
    admin_id integer NOT NULL
);


-- ALTER TABLEaccount_admin OWNER TO openchs;

--
-- Name: account_admin_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE account_admin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEaccount_admin_id_seq OWNER TO openchs;

--
-- Name: account_admin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEaccount_admin_id_seq OWNED BY account_admin.id;


--
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEaccount_id_seq OWNER TO openchs;

--
-- Name: account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEaccount_id_seq OWNED BY account.id;


--
-- Name: address_level; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE address_level (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    type_id integer,
    lineage ltree,
    parent_id integer
--     CONSTRAINT lineage_parent_consistency CHECK ((((parent_id IS NOT NULL) AND (subltree(lineage, 0, nlevel(lineage)) ~ (concat('*.', parent_id, '.', id))::lquery)) OR ((parent_id IS NULL) AND (lineage ~ (concat('', id))::lquery))))
);


-- ALTER TABLEaddress_level OWNER TO openchs;

--
-- Name: address_level_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE address_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEaddress_level_id_seq OWNER TO openchs;

--
-- Name: address_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEaddress_level_id_seq OWNED BY address_level.id;


--
-- Name: address_level_type; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE address_level_type (
    id integer NOT NULL,
    uuid character varying(255) DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer NOT NULL,
    version integer NOT NULL,
    audit_id integer,
    level double,
    parent_id integer
);


-- ALTER TABLEaddress_level_type OWNER TO openchs;

--
-- Name: address_level_type_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE address_level_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEaddress_level_type_id_seq OWNER TO openchs;

--
-- Name: address_level_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEaddress_level_type_id_seq OWNED BY address_level_type.id;


--
-- Name: organisation; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE organisation (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    db_user character varying(255) NOT NULL,
    uuid character varying(255) NOT NULL,
    parent_organisation_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    media_directory text,
    username_suffix text,
    account_id integer DEFAULT 1 NOT NULL
);


-- ALTER TABLEorganisation OWNER TO openchs;

--
-- Name: address_level_type_view; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW address_level_type_view AS
 WITH RECURSIVE list_of_orgs(id, parent_organisation_id) AS (
         SELECT organisation.id,
            organisation.parent_organisation_id
           FROM organisation
          WHERE ((organisation.db_user)::name = "current_user"())
        UNION ALL
         SELECT o.id,
            o.parent_organisation_id
           FROM organisation o,
            list_of_orgs log
          WHERE (o.id = log.parent_organisation_id)
        )
 SELECT al.id,
    al.title,
    al.uuid,
    alt.level,
    al.version,
    al.organisation_id,
    al.audit_id,
    al.is_voided,
    al.type_id,
    alt.name AS type
   FROM ((address_level al
     JOIN address_level_type alt ON ((al.type_id = alt.id)))
     JOIN list_of_orgs loo ON ((loo.id = al.organisation_id)))
  WHERE (alt.is_voided IS NOT TRUE);


-- ALTER TABLEaddress_level_type_view OWNER TO openchs;

--
-- Name: form; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE form (
    id integer NOT NULL,
    name character varying(255),
    form_type character varying(255) NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    decision_rule text,
    validation_rule text,
    visit_schedule_rule text,
    checklists_rule text
);


-- ALTER TABLEform OWNER TO openchs;

--
-- Name: form_mapping; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE form_mapping (
    id integer NOT NULL,
    form_id bigint,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    entity_id bigint,
    observations_type_entity_id integer,
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    subject_type_id integer NOT NULL
);


-- ALTER TABLEform_mapping OWNER TO openchs;

--
-- Name: operational_encounter_type; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE operational_encounter_type (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    organisation_id integer NOT NULL,
    encounter_type_id integer NOT NULL,
    version integer NOT NULL,
    audit_id integer,
    name character varying(255),
    is_voided boolean DEFAULT false NOT NULL
);


-- ALTER TABLEoperational_encounter_type OWNER TO openchs;

--
-- Name: operational_program; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE operational_program (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    organisation_id integer NOT NULL,
    program_id integer NOT NULL,
    version integer NOT NULL,
    audit_id integer,
    name character varying(255),
    is_voided boolean DEFAULT false NOT NULL,
    program_subject_label text
);


-- ALTER TABLEoperational_program OWNER TO openchs;

--
-- Name: all_forms; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW all_forms AS
 SELECT DISTINCT x.organisation_id,
    x.form_id,
    x.form_name
   FROM ( SELECT form.id AS form_id,
            form.name AS form_name,
            m2.organisation_id
           FROM (form
             JOIN form_mapping m2 ON ((form.id = m2.form_id)))
          WHERE ((NOT form.is_voided) OR (NOT m2.is_voided))
        UNION
         SELECT form.id AS form_id,
            form.name AS form_name,
            oet.organisation_id
           FROM ((form
             JOIN form_mapping m2 ON (((form.id = m2.form_id) AND (m2.organisation_id = 1))))
             JOIN operational_encounter_type oet ON ((oet.encounter_type_id = m2.observations_type_entity_id)))
          WHERE ((NOT form.is_voided) OR (NOT m2.is_voided) OR (NOT oet.is_voided))
        UNION
         SELECT form.id AS form_id,
            form.name AS form_name,
            op.organisation_id
           FROM ((form
             JOIN form_mapping m2 ON (((form.id = m2.form_id) AND (m2.organisation_id = 1))))
             JOIN operational_program op ON ((op.program_id = m2.entity_id)))
          WHERE ((NOT form.is_voided) OR (NOT m2.is_voided) OR (NOT op.is_voided))) x;


-- ALTER TABLEall_forms OWNER TO openchs;

--
-- Name: concept; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE concept (
    id integer NOT NULL,
    data_type character varying(255) NOT NULL,
    high_absolute double,
    high_normal double,
    low_absolute double,
    low_normal double,
    name character varying(255) NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    unit character varying(50),
    organisation_id integer DEFAULT 1 NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    audit_id integer,
    key_values jsonb,
    active boolean DEFAULT true NOT NULL
);


-- ALTER TABLEconcept OWNER TO openchs;

--
-- Name: concept_answer; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE concept_answer (
    id integer NOT NULL,
    concept_id bigint NOT NULL,
    answer_concept_id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    answer_order double NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    abnormal boolean DEFAULT false NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    uniq boolean DEFAULT false NOT NULL,
    audit_id integer
);


-- ALTER TABLEconcept_answer OWNER TO openchs;

--
-- Name: form_element; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE form_element (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_order double  NOT NULL,
    is_mandatory boolean DEFAULT false NOT NULL,
    key_values jsonb,
    concept_id bigint NOT NULL,
    form_element_group_id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    type character varying(1024),
    valid_format_regex character varying(255),
    valid_format_description_key character varying(255),
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    rule text,
    CONSTRAINT valid_format_check CHECK ((((valid_format_regex IS NULL) AND (valid_format_description_key IS NULL)) OR ((valid_format_regex IS NOT NULL) AND (valid_format_description_key IS NOT NULL))))
);


-- ALTER TABLEform_element OWNER TO openchs;

--
-- Name: form_element_group; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE form_element_group (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    form_id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    display_order double,
    display character varying(100),
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    rule text
);


-- ALTER TABLEform_element_group OWNER TO openchs;

--
-- Name: all_concept_answers; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW all_concept_answers AS
 SELECT DISTINCT all_forms.organisation_id,
    c3.name AS answer_concept_name
   FROM ((((((form_element
     JOIN form_element_group ON ((form_element.form_element_group_id = form_element_group.id)))
     JOIN form ON ((form_element_group.form_id = form.id)))
     JOIN concept c2 ON ((form_element.concept_id = c2.id)))
     JOIN concept_answer a ON ((c2.id = a.concept_id)))
     JOIN concept c3 ON ((a.answer_concept_id = c3.id)))
     JOIN all_forms ON ((all_forms.form_id = form.id)))
  WHERE ((NOT form_element.is_voided) OR (NOT form_element_group.is_voided) OR (NOT form.is_voided) OR (NOT c2.is_voided) OR (NOT c2.is_voided) OR (NOT c3.is_voided));


-- ALTER TABLEall_concept_answers OWNER TO openchs;

--
-- Name: all_concepts; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW all_concepts AS
 SELECT DISTINCT all_forms.organisation_id,
    c2.name AS concept_name
   FROM ((((form_element
     JOIN form_element_group ON ((form_element.form_element_group_id = form_element_group.id)))
     JOIN form ON ((form_element_group.form_id = form.id)))
     JOIN concept c2 ON ((form_element.concept_id = c2.id)))
     JOIN all_forms ON ((all_forms.form_id = form.id)))
  WHERE ((NOT form_element.is_voided) OR (NOT form_element_group.is_voided) OR (NOT form.is_voided) OR (NOT c2.is_voided));


-- ALTER TABLEall_concepts OWNER TO openchs;

--
-- Name: encounter_type; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE encounter_type (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    concept_id bigint,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    encounter_eligibility_check_rule text,
    active boolean DEFAULT true NOT NULL
);


-- ALTER TABLEencounter_type OWNER TO openchs;

--
-- Name: all_encounter_types; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW all_encounter_types AS
 SELECT DISTINCT operational_encounter_type.organisation_id,
    et.name AS encounter_type_name
   FROM (operational_encounter_type
     JOIN encounter_type et ON ((operational_encounter_type.encounter_type_id = et.id)))
  WHERE ((NOT operational_encounter_type.is_voided) OR (NOT et.is_voided));


-- ALTER TABLEall_encounter_types OWNER TO openchs;

--
-- Name: all_form_element_groups; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW all_form_element_groups AS
 SELECT DISTINCT all_forms.organisation_id,
    form_element_group.name AS form_element_group_name
   FROM ((form_element_group
     JOIN form ON ((form_element_group.form_id = form.id)))
     JOIN all_forms ON ((all_forms.form_id = form.id)))
  WHERE ((NOT form_element_group.is_voided) OR (NOT form.is_voided));


-- ALTER TABLEall_form_element_groups OWNER TO openchs;

--
-- Name: all_form_elements; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW all_form_elements AS
 SELECT DISTINCT all_forms.organisation_id,
    form_element.name AS form_element_name
   FROM (((form_element
     JOIN form_element_group ON ((form_element.form_element_group_id = form_element_group.id)))
     JOIN form ON ((form_element_group.form_id = form.id)))
     JOIN all_forms ON ((all_forms.form_id = form.id)))
  WHERE ((NOT form_element.is_voided) OR (NOT form_element_group.is_voided));


-- ALTER TABLEall_form_elements OWNER TO openchs;

--
-- Name: all_operational_encounter_types; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW all_operational_encounter_types AS
 SELECT DISTINCT operational_encounter_type.organisation_id,
    operational_encounter_type.name AS operational_encounter_type_name
   FROM (operational_encounter_type
     JOIN encounter_type et ON ((operational_encounter_type.encounter_type_id = et.id)))
  WHERE ((NOT operational_encounter_type.is_voided) OR (NOT et.is_voided));


-- ALTER TABLEall_operational_encounter_types OWNER TO openchs;

--
-- Name: program; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE program (
    id smallint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    version integer NOT NULL,
    colour character varying(20),
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    enrolment_summary_rule text,
    enrolment_eligibility_check_rule text,
    active boolean DEFAULT true NOT NULL
);


-- ALTER TABLEprogram OWNER TO openchs;

--
-- Name: all_operational_programs; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW all_operational_programs AS
 SELECT DISTINCT operational_program.organisation_id,
    operational_program.name AS operational_program_name
   FROM (operational_program
     JOIN program p ON ((p.id = operational_program.program_id)))
  WHERE ((NOT operational_program.is_voided) OR (NOT p.is_voided));


-- ALTER TABLEall_operational_programs OWNER TO openchs;

--
-- Name: all_programs; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW all_programs AS
 SELECT DISTINCT operational_program.organisation_id,
    p.name AS program_name
   FROM (operational_program
     JOIN program p ON ((p.id = operational_program.program_id)))
  WHERE ((NOT operational_program.is_voided) OR (NOT p.is_voided));


-- ALTER TABLEall_programs OWNER TO openchs;

--
-- Name: audit; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE audit (
    id integer NOT NULL,
    uuid character varying(255),
    created_by_id bigint NOT NULL,
    last_modified_by_id bigint NOT NULL,
    created_date_time timestamp with time zone NOT NULL,
    last_modified_date_time timestamp with time zone NOT NULL
);


-- ALTER TABLEaudit OWNER TO openchs;

--
-- Name: audit_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEaudit_id_seq OWNER TO openchs;

--
-- Name: audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEaudit_id_seq OWNED BY audit.id;


--
-- Name: batch_job_execution; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE batch_job_execution (
    job_execution_id bigint NOT NULL,
    version bigint,
    job_instance_id bigint NOT NULL,
    create_time timestamp without time zone NOT NULL,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    status character varying(10),
    exit_code character varying(2500),
    exit_message character varying(2500),
    last_updated timestamp without time zone,
    job_configuration_location character varying(2500)
);


-- ALTER TABLEbatch_job_execution OWNER TO openchs;

--
-- Name: batch_job_execution_context; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE batch_job_execution_context (
    job_execution_id bigint NOT NULL,
    short_context character varying(2500) NOT NULL,
    serialized_context text
);


-- ALTER TABLEbatch_job_execution_context OWNER TO openchs;

--
-- Name: batch_job_execution_params; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE batch_job_execution_params (
    job_execution_id bigint NOT NULL,
    type_cd character varying(6) NOT NULL,
    key_name character varying(100) NOT NULL,
    string_val character varying(250),
    date_val timestamp without time zone,
    long_val bigint,
    double_val double ,
    identifying character(1) NOT NULL
);


-- ALTER TABLEbatch_job_execution_params OWNER TO openchs;

--
-- Name: batch_job_execution_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE batch_job_execution_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEbatch_job_execution_seq OWNER TO openchs;

--
-- Name: batch_job_instance; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE batch_job_instance (
    job_instance_id bigint NOT NULL,
    version bigint,
    job_name character varying(100) NOT NULL,
    job_key character varying(32) NOT NULL
);


-- ALTER TABLEbatch_job_instance OWNER TO openchs;

--
-- Name: batch_job_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE batch_job_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEbatch_job_seq OWNER TO openchs;

--
-- Name: batch_step_execution; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE batch_step_execution (
    step_execution_id bigint NOT NULL,
    version bigint NOT NULL,
    step_name character varying(100) NOT NULL,
    job_execution_id bigint NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    status character varying(10),
    commit_count bigint,
    read_count bigint,
    filter_count bigint,
    write_count bigint,
    read_skip_count bigint,
    write_skip_count bigint,
    process_skip_count bigint,
    rollback_count bigint,
    exit_code character varying(2500),
    exit_message character varying(2500),
    last_updated timestamp without time zone
);


-- ALTER TABLEbatch_step_execution OWNER TO openchs;

--
-- Name: batch_step_execution_context; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE batch_step_execution_context (
    step_execution_id bigint NOT NULL,
    short_context character varying(2500) NOT NULL,
    serialized_context text
);


-- ALTER TABLEbatch_step_execution_context OWNER TO openchs;

--
-- Name: batch_step_execution_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE batch_step_execution_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEbatch_step_execution_seq OWNER TO openchs;

--
-- Name: catchment; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE catchment (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    type character varying(1024),
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL
);


-- ALTER TABLEcatchment OWNER TO openchs;

--
-- Name: catchment_address_mapping; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE catchment_address_mapping (
    id integer NOT NULL,
    catchment_id bigint NOT NULL,
    addresslevel_id bigint NOT NULL
);


-- ALTER TABLEcatchment_address_mapping OWNER TO openchs;

--
-- Name: catchment_address_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE catchment_address_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEcatchment_address_mapping_id_seq OWNER TO openchs;

--
-- Name: catchment_address_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEcatchment_address_mapping_id_seq OWNED BY catchment_address_mapping.id;


--
-- Name: catchment_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE catchment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEcatchment_id_seq OWNER TO openchs;

--
-- Name: catchment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEcatchment_id_seq OWNED BY catchment.id;


--
-- Name: checklist; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE checklist (
    id integer NOT NULL,
    program_enrolment_id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    base_date timestamp with time zone NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    checklist_detail_id integer
);


-- ALTER TABLEchecklist OWNER TO openchs;

--
-- Name: checklist_detail; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE checklist_detail (
    id smallint NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    audit_id integer NOT NULL,
    name character varying NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer NOT NULL
);


-- ALTER TABLEchecklist_detail OWNER TO openchs;

--
-- Name: checklist_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE checklist_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEchecklist_detail_id_seq OWNER TO openchs;

--
-- Name: checklist_detail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEchecklist_detail_id_seq OWNED BY checklist_detail.id;


--
-- Name: checklist_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE checklist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEchecklist_id_seq OWNER TO openchs;

--
-- Name: checklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEchecklist_id_seq OWNED BY checklist.id;


--
-- Name: checklist_item; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE checklist_item (
    id integer NOT NULL,
    completion_date timestamp with time zone,
    checklist_id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    observations jsonb,
    checklist_item_detail_id integer
);


-- ALTER TABLEchecklist_item OWNER TO openchs;

--
-- Name: checklist_item_detail; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE checklist_item_detail (
    id smallint NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    audit_id integer NOT NULL,
    form_id integer NOT NULL,
    concept_id integer NOT NULL,
    checklist_detail_id integer NOT NULL,
    status jsonb,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer NOT NULL,
    dependent_on integer,
    schedule_on_expiry_of_dependency boolean DEFAULT false NOT NULL,
    min_days_from_start_date smallint,
    min_days_from_dependent integer,
    expires_after integer
);


-- ALTER TABLEchecklist_item_detail OWNER TO openchs;

--
-- Name: checklist_item_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE checklist_item_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEchecklist_item_detail_id_seq OWNER TO openchs;

--
-- Name: checklist_item_detail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEchecklist_item_detail_id_seq OWNED BY checklist_item_detail.id;


--
-- Name: checklist_item_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE checklist_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEchecklist_item_id_seq OWNER TO openchs;

--
-- Name: checklist_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEchecklist_item_id_seq OWNED BY checklist_item.id;


--
-- Name: concept_answer_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE concept_answer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEconcept_answer_id_seq OWNER TO openchs;

--
-- Name: concept_answer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEconcept_answer_id_seq OWNED BY concept_answer.id;


--
-- Name: concept_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE concept_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEconcept_id_seq OWNER TO openchs;

--
-- Name: concept_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEconcept_id_seq OWNED BY concept.id;


--
-- Name: deps_saved_ddl; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE deps_saved_ddl (
    deps_id integer NOT NULL,
    deps_view_schema character varying(255),
    deps_view_name character varying(255),
    deps_ddl_to_run text
);


-- ALTER TABLEdeps_saved_ddl OWNER TO openchs;

--
-- Name: deps_saved_ddl_deps_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE deps_saved_ddl_deps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEdeps_saved_ddl_deps_id_seq OWNER TO openchs;

--
-- Name: deps_saved_ddl_deps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEdeps_saved_ddl_deps_id_seq OWNED BY deps_saved_ddl.deps_id;


--
-- Name: encounter; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE encounter (
    id integer NOT NULL,
    observations jsonb NOT NULL,
    encounter_date_time timestamp with time zone,
    encounter_type_id integer NOT NULL,
    individual_id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    audit_id integer,
    encounter_location point,
    earliest_visit_date_time timestamp with time zone,
    max_visit_date_time timestamp with time zone,
    cancel_date_time timestamp with time zone,
    cancel_observations jsonb,
    cancel_location point,
    name text,
    legacy_id character varying
);


-- ALTER TABLEencounter OWNER TO openchs;

--
-- Name: encounter_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE encounter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEencounter_id_seq OWNER TO openchs;

--
-- Name: encounter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEencounter_id_seq OWNED BY encounter.id;


--
-- Name: encounter_type_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE encounter_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEencounter_type_id_seq OWNER TO openchs;

--
-- Name: encounter_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEencounter_type_id_seq OWNED BY encounter_type.id;


--
-- Name: facility; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE facility (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    address_id bigint,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer NOT NULL,
    version integer NOT NULL,
    audit_id integer
);


-- ALTER TABLEfacility OWNER TO openchs;

--
-- Name: facility_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE facility_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEfacility_id_seq OWNER TO openchs;

--
-- Name: facility_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEfacility_id_seq OWNED BY facility.id;


--
-- Name: form_element_group_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE form_element_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEform_element_group_id_seq OWNER TO openchs;

--
-- Name: form_element_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEform_element_group_id_seq OWNED BY form_element_group.id;


--
-- Name: form_element_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE form_element_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEform_element_id_seq OWNER TO openchs;

--
-- Name: form_element_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEform_element_id_seq OWNED BY form_element.id;


--
-- Name: form_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE form_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEform_id_seq OWNER TO openchs;

--
-- Name: form_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEform_id_seq OWNED BY form.id;


--
-- Name: form_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE form_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEform_mapping_id_seq OWNER TO openchs;

--
-- Name: form_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEform_mapping_id_seq OWNED BY form_mapping.id;


--
-- Name: gender; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE gender (
    id smallint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    concept_id bigint,
    version integer NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer NOT NULL
);


-- ALTER TABLEgender OWNER TO openchs;

--
-- Name: gender_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE gender_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEgender_id_seq OWNER TO openchs;

--
-- Name: gender_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEgender_id_seq OWNED BY gender.id;


--
-- Name: group_privilege; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE group_privilege (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    group_id integer NOT NULL,
    privilege_id integer NOT NULL,
    subject_type_id integer,
    program_id integer,
    program_encounter_type_id integer,
    encounter_type_id integer,
    checklist_detail_id integer,
    allow boolean DEFAULT false NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    version integer,
    organisation_id integer NOT NULL,
    audit_id integer
);


-- ALTER TABLEgroup_privilege OWNER TO openchs;

--
-- Name: group_privilege_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE group_privilege_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEgroup_privilege_id_seq OWNER TO openchs;

--
-- Name: group_privilege_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEgroup_privilege_id_seq OWNED BY group_privilege.id;


--
-- Name: group_role; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE group_role (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    group_subject_type_id integer NOT NULL,
    role text,
    member_subject_type_id integer NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    maximum_number_of_members integer NOT NULL,
    minimum_number_of_members integer NOT NULL,
    organisation_id integer NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    version integer
);


-- ALTER TABLEgroup_role OWNER TO openchs;

--
-- Name: group_role_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE group_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEgroup_role_id_seq OWNER TO openchs;

--
-- Name: group_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEgroup_role_id_seq OWNED BY group_role.id;


--
-- Name: group_subject; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE group_subject (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    group_subject_id integer NOT NULL,
    member_subject_id integer NOT NULL,
    group_role_id integer NOT NULL,
    membership_start_date timestamp with time zone,
    membership_end_date timestamp with time zone,
    organisation_id integer NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    version integer
);


-- ALTER TABLEgroup_subject OWNER TO openchs;

--
-- Name: group_subject_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE group_subject_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEgroup_subject_id_seq OWNER TO openchs;

--
-- Name: group_subject_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEgroup_subject_id_seq OWNED BY group_subject.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE groups (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    version integer,
    organisation_id integer NOT NULL,
    audit_id integer,
    has_all_privileges boolean DEFAULT false NOT NULL
);


-- ALTER TABLEgroups OWNER TO openchs;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEgroups_id_seq OWNER TO openchs;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEgroups_id_seq OWNED BY groups.id;


--
-- Name: identifier_assignment; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE identifier_assignment (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    identifier_source_id integer NOT NULL,
    identifier text NOT NULL,
    assignment_order integer NOT NULL,
    assigned_to_user_id integer NOT NULL,
    individual_id integer,
    program_enrolment_id integer,
    version integer NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer NOT NULL
);


-- ALTER TABLEidentifier_assignment OWNER TO openchs;

--
-- Name: identifier_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE identifier_assignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEidentifier_assignment_id_seq OWNER TO openchs;

--
-- Name: identifier_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEidentifier_assignment_id_seq OWNED BY identifier_assignment.id;


--
-- Name: identifier_source; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE identifier_source (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    type text NOT NULL,
    catchment_id integer,
    facility_id integer,
    minimum_balance integer DEFAULT 20 NOT NULL,
    batch_generation_size integer DEFAULT 100 NOT NULL,
    options jsonb,
    version integer NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer NOT NULL,
    min_length integer DEFAULT 0 NOT NULL,
    max_length integer DEFAULT 0 NOT NULL
);


-- ALTER TABLEidentifier_source OWNER TO openchs;

--
-- Name: identifier_source_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE identifier_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEidentifier_source_id_seq OWNER TO openchs;

--
-- Name: identifier_source_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEidentifier_source_id_seq OWNED BY identifier_source.id;


--
-- Name: identifier_user_assignment; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE identifier_user_assignment (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    identifier_source_id integer NOT NULL,
    assigned_to_user_id integer NOT NULL,
    identifier_start text NOT NULL,
    identifier_end text NOT NULL,
    last_assigned_identifier text,
    version integer NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer NOT NULL
);


-- ALTER TABLEidentifier_user_assignment OWNER TO openchs;

--
-- Name: identifier_user_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE identifier_user_assignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEidentifier_user_assignment_id_seq OWNER TO openchs;

--
-- Name: identifier_user_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEidentifier_user_assignment_id_seq OWNED BY identifier_user_assignment.id;


--
-- Name: individual; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE individual (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    address_id bigint NOT NULL,
    observations jsonb,
    version integer NOT NULL,
    date_of_birth date,
    date_of_birth_verified boolean NOT NULL,
    gender_id bigint,
    registration_date date,
    organisation_id integer DEFAULT 1 NOT NULL,
    first_name character varying(256),
    last_name character varying(256),
    is_voided boolean DEFAULT false NOT NULL,
    audit_id integer,
    facility_id bigint,
    registration_location point,
    subject_type_id integer NOT NULL,
    legacy_id character varying
);


-- ALTER TABLEindividual OWNER TO openchs;

--
-- Name: individual_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE individual_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEindividual_id_seq OWNER TO openchs;

--
-- Name: individual_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEindividual_id_seq OWNED BY individual.id;


--
-- Name: individual_relation; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE individual_relation (
    id smallint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer NOT NULL,
    version integer NOT NULL,
    audit_id integer
);


-- ALTER TABLEindividual_relation OWNER TO openchs;

--
-- Name: individual_relation_gender_mapping; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE individual_relation_gender_mapping (
    id smallint NOT NULL,
    uuid character varying(255) NOT NULL,
    relation_id smallint NOT NULL,
    gender_id smallint NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer NOT NULL,
    version integer NOT NULL,
    audit_id integer
);


-- ALTER TABLEindividual_relation_gender_mapping OWNER TO openchs;

--
-- Name: individual_relation_gender_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE individual_relation_gender_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEindividual_relation_gender_mapping_id_seq OWNER TO openchs;

--
-- Name: individual_relation_gender_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEindividual_relation_gender_mapping_id_seq OWNED BY individual_relation_gender_mapping.id;


--
-- Name: individual_relation_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE individual_relation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEindividual_relation_id_seq OWNER TO openchs;

--
-- Name: individual_relation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEindividual_relation_id_seq OWNED BY individual_relation.id;


--
-- Name: individual_relationship; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE individual_relationship (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    individual_a_id bigint NOT NULL,
    individual_b_id bigint NOT NULL,
    relationship_type_id smallint NOT NULL,
    enter_date_time timestamp with time zone,
    exit_date_time timestamp with time zone,
    exit_observations jsonb,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer NOT NULL,
    version integer NOT NULL,
    audit_id integer
);


-- ALTER TABLEindividual_relationship OWNER TO openchs;

--
-- Name: individual_relationship_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE individual_relationship_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEindividual_relationship_id_seq OWNER TO openchs;

--
-- Name: individual_relationship_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEindividual_relationship_id_seq OWNED BY individual_relationship.id;


--
-- Name: individual_relationship_type; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE individual_relationship_type (
    id smallint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    individual_a_is_to_b_relation_id smallint NOT NULL,
    individual_b_is_to_a_relation_id smallint NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer NOT NULL,
    version integer NOT NULL,
    audit_id integer
);


-- ALTER TABLEindividual_relationship_type OWNER TO openchs;

--
-- Name: individual_relationship_type_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE individual_relationship_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEindividual_relationship_type_id_seq OWNER TO openchs;

--
-- Name: individual_relationship_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEindividual_relationship_type_id_seq OWNED BY individual_relationship_type.id;


--
-- Name: individual_relative; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE individual_relative (
    id smallint NOT NULL,
    uuid character varying(255) NOT NULL,
    individual_id bigint NOT NULL,
    relative_individual_id bigint NOT NULL,
    relation_id smallint NOT NULL,
    enter_date_time timestamp with time zone,
    exit_date_time timestamp with time zone,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id integer NOT NULL,
    version integer NOT NULL,
    audit_id integer
);


-- ALTER TABLEindividual_relative OWNER TO openchs;

--
-- Name: individual_relative_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE individual_relative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEindividual_relative_id_seq OWNER TO openchs;

--
-- Name: individual_relative_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEindividual_relative_id_seq OWNED BY individual_relative.id;


--
-- Name: location_location_mapping; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE location_location_mapping (
    id integer NOT NULL,
    location_id bigint,
    parent_location_id bigint,
    version integer NOT NULL,
    audit_id bigint,
    uuid character varying(255) NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id bigint
);


-- ALTER TABLElocation_location_mapping OWNER TO openchs;

--
-- Name: location_location_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE location_location_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLElocation_location_mapping_id_seq OWNER TO openchs;

--
-- Name: location_location_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCElocation_location_mapping_id_seq OWNED BY location_location_mapping.id;


--
-- Name: non_applicable_form_element; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE non_applicable_form_element (
    id integer NOT NULL,
    organisation_id bigint,
    form_element_id bigint,
    is_voided boolean DEFAULT false NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    audit_id integer,
    uuid character varying(255) NOT NULL
);


-- ALTER TABLEnon_applicable_form_element OWNER TO openchs;

--
-- Name: non_applicable_form_element_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE non_applicable_form_element_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEnon_applicable_form_element_id_seq OWNER TO openchs;

--
-- Name: non_applicable_form_element_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEnon_applicable_form_element_id_seq OWNED BY non_applicable_form_element.id;


--
-- Name: operational_encounter_type_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE operational_encounter_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEoperational_encounter_type_id_seq OWNER TO openchs;

--
-- Name: operational_encounter_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEoperational_encounter_type_id_seq OWNED BY operational_encounter_type.id;


--
-- Name: operational_program_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE operational_program_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEoperational_program_id_seq OWNER TO openchs;

--
-- Name: operational_program_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEoperational_program_id_seq OWNED BY operational_program.id;


--
-- Name: operational_subject_type; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE operational_subject_type (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    subject_type_id integer NOT NULL,
    organisation_id bigint NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    audit_id bigint NOT NULL,
    version integer DEFAULT 1
);


-- ALTER TABLEoperational_subject_type OWNER TO openchs;

--
-- Name: operational_subject_type_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE operational_subject_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEoperational_subject_type_id_seq OWNER TO openchs;

--
-- Name: operational_subject_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEoperational_subject_type_id_seq OWNED BY operational_subject_type.id;


--
-- Name: org_ids; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW org_ids WITH (security_barrier='true') AS
 WITH RECURSIVE list_of_orgs(id, parent_organisation_id) AS (
         SELECT organisation.id,
            organisation.parent_organisation_id
           FROM organisation
          WHERE ((organisation.db_user)::name = "current_user"())
        UNION ALL
         SELECT o.id,
            o.parent_organisation_id
           FROM organisation o,
            list_of_orgs log
          WHERE (o.id = log.parent_organisation_id)
        )
 SELECT list_of_orgs.id
   FROM list_of_orgs;


-- ALTER TABLEorg_ids OWNER TO openchs;

--
-- Name: organisation_config; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE organisation_config (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    organisation_id bigint NOT NULL,
    settings jsonb,
    audit_id bigint,
    version integer DEFAULT 1,
    is_voided boolean DEFAULT false,
    worklist_updation_rule text
);


-- ALTER TABLEorganisation_config OWNER TO openchs;

--
-- Name: organisation_config_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE organisation_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEorganisation_config_id_seq OWNER TO openchs;

--
-- Name: organisation_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEorganisation_config_id_seq OWNED BY organisation_config.id;


--
-- Name: organisation_group; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE organisation_group (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    db_user character varying(255) NOT NULL,
    account_id integer NOT NULL
);


-- ALTER TABLEorganisation_group OWNER TO openchs;

--
-- Name: organisation_group_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE organisation_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEorganisation_group_id_seq OWNER TO openchs;

--
-- Name: organisation_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEorganisation_group_id_seq OWNED BY organisation_group.id;


--
-- Name: organisation_group_organisation; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE organisation_group_organisation (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    organisation_group_id integer NOT NULL,
    organisation_id integer NOT NULL
);


-- ALTER TABLEorganisation_group_organisation OWNER TO openchs;

--
-- Name: organisation_group_organisation_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE organisation_group_organisation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEorganisation_group_organisation_id_seq OWNER TO openchs;

--
-- Name: organisation_group_organisation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEorganisation_group_organisation_id_seq OWNED BY organisation_group_organisation.id;


--
-- Name: organisation_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE organisation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEorganisation_id_seq OWNER TO openchs;

--
-- Name: organisation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEorganisation_id_seq OWNED BY organisation.id;


--
-- Name: platform_translation; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE platform_translation (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    translation_json jsonb NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    platform character varying(255) NOT NULL,
    language character varying(255),
    created_date_time timestamp with time zone,
    last_modified_date_time timestamp with time zone
);


-- ALTER TABLEplatform_translation OWNER TO openchs;

--
-- Name: platform_translation_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE platform_translation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEplatform_translation_id_seq OWNER TO openchs;

--
-- Name: platform_translation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEplatform_translation_id_seq OWNED BY platform_translation.id;


--
-- Name: privilege; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE privilege (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    entity_type character varying(255) NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    created_date_time timestamp with time zone,
    last_modified_date_time timestamp with time zone
);


-- ALTER TABLEprivilege OWNER TO openchs;

--
-- Name: privilege_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE privilege_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEprivilege_id_seq OWNER TO openchs;

--
-- Name: privilege_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEprivilege_id_seq OWNED BY privilege.id;


--
-- Name: program_encounter; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE program_encounter (
    id integer NOT NULL,
    observations jsonb NOT NULL,
    earliest_visit_date_time timestamp with time zone,
    encounter_date_time timestamp with time zone,
    program_enrolment_id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    encounter_type_id integer DEFAULT 1 NOT NULL,
    name character varying(255),
    max_visit_date_time timestamp with time zone,
    organisation_id integer DEFAULT 1 NOT NULL,
    cancel_date_time timestamp with time zone,
    cancel_observations jsonb,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    encounter_location point,
    cancel_location point,
    legacy_id character varying,
    CONSTRAINT program_encounter_cannot_cancel_and_perform_check CHECK (((encounter_date_time IS NULL) OR (cancel_date_time IS NULL)))
);


-- ALTER TABLEprogram_encounter OWNER TO openchs;

--
-- Name: program_encounter_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE program_encounter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEprogram_encounter_id_seq OWNER TO openchs;

--
-- Name: program_encounter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEprogram_encounter_id_seq OWNED BY program_encounter.id;


--
-- Name: program_enrolment; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE program_enrolment (
    id integer NOT NULL,
    program_id smallint NOT NULL,
    individual_id bigint NOT NULL,
    program_outcome_id smallint,
    observations jsonb,
    program_exit_observations jsonb,
    enrolment_date_time timestamp with time zone NOT NULL,
    program_exit_date_time timestamp with time zone,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    enrolment_location point,
    exit_location point,
    legacy_id character varying
);


-- ALTER TABLEprogram_enrolment OWNER TO openchs;

--
-- Name: program_enrolment_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE program_enrolment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEprogram_enrolment_id_seq OWNER TO openchs;

--
-- Name: program_enrolment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEprogram_enrolment_id_seq OWNED BY program_enrolment.id;


--
-- Name: program_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE program_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEprogram_id_seq OWNER TO openchs;

--
-- Name: program_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEprogram_id_seq OWNED BY program.id;


--
-- Name: program_organisation_config; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE program_organisation_config (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    program_id bigint NOT NULL,
    organisation_id bigint NOT NULL,
    visit_schedule jsonb,
    version integer NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL
);


-- ALTER TABLEprogram_organisation_config OWNER TO openchs;

--
-- Name: program_organisation_config_at_risk_concept; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE program_organisation_config_at_risk_concept (
    id integer NOT NULL,
    program_organisation_config_id integer NOT NULL,
    concept_id integer NOT NULL
);


-- ALTER TABLEprogram_organisation_config_at_risk_concept OWNER TO openchs;

--
-- Name: program_organisation_config_at_risk_concept_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE program_organisation_config_at_risk_concept_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEprogram_organisation_config_at_risk_concept_id_seq OWNER TO openchs;

--
-- Name: program_organisation_config_at_risk_concept_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEprogram_organisation_config_at_risk_concept_id_seq OWNED BY program_organisation_config_at_risk_concept.id;


--
-- Name: program_organisation_config_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE program_organisation_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEprogram_organisation_config_id_seq OWNER TO openchs;

--
-- Name: program_organisation_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEprogram_organisation_config_id_seq OWNED BY program_organisation_config.id;


--
-- Name: program_outcome; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE program_outcome (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    version integer NOT NULL,
    organisation_id integer DEFAULT 1 NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL
);


-- ALTER TABLEprogram_outcome OWNER TO openchs;

--
-- Name: program_outcome_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE program_outcome_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEprogram_outcome_id_seq OWNER TO openchs;

--
-- Name: program_outcome_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEprogram_outcome_id_seq OWNED BY program_outcome.id;


--
-- Name: rule; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE rule (
    id smallint NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    audit_id integer NOT NULL,
    type character varying NOT NULL,
    rule_dependency_id integer,
    name character varying NOT NULL,
    fn_name character varying NOT NULL,
    data jsonb,
    organisation_id integer NOT NULL,
    execution_order double  DEFAULT 10000.0 NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    entity jsonb NOT NULL
);


-- ALTER TABLErule OWNER TO openchs;

--
-- Name: rule_dependency; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE rule_dependency (
    id smallint NOT NULL,
    uuid character varying(255) NOT NULL,
    version integer NOT NULL,
    audit_id integer NOT NULL,
    checksum character varying NOT NULL,
    code text NOT NULL,
    organisation_id integer NOT NULL,
    is_voided boolean DEFAULT false NOT NULL
);


-- ALTER TABLErule_dependency OWNER TO openchs;

--
-- Name: rule_dependency_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE rule_dependency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLErule_dependency_id_seq OWNER TO openchs;

--
-- Name: rule_dependency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCErule_dependency_id_seq OWNED BY rule_dependency.id;


--
-- Name: rule_failure_log; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE rule_failure_log (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    form_id character varying(255) NOT NULL,
    rule_type character varying(255) NOT NULL,
    entity_type character varying(255) NOT NULL,
    entity_id character varying(255) NOT NULL,
    error_message character varying(255) NOT NULL,
    stacktrace text NOT NULL,
    source character varying(255) NOT NULL,
    audit_id integer,
    is_voided boolean DEFAULT false NOT NULL,
    version integer NOT NULL,
    organisation_id bigint NOT NULL
);


-- ALTER TABLErule_failure_log OWNER TO openchs;

--
-- Name: rule_failure_log_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE rule_failure_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLErule_failure_log_id_seq OWNER TO openchs;

--
-- Name: rule_failure_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCErule_failure_log_id_seq OWNED BY rule_failure_log.id;


--
-- Name: rule_failure_telemetry; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE rule_failure_telemetry (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    user_id integer NOT NULL,
    organisation_id bigint NOT NULL,
    version integer DEFAULT 1,
    rule_uuid character varying(255) NOT NULL,
    individual_uuid character varying(255) NOT NULL,
    error_message character varying(255) NOT NULL,
    stacktrace text NOT NULL,
    error_date_time timestamp with time zone,
    close_date_time timestamp with time zone,
    is_closed boolean DEFAULT false NOT NULL,
    audit_id bigint
);


-- ALTER TABLErule_failure_telemetry OWNER TO openchs;

--
-- Name: rule_failure_telemetry_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE rule_failure_telemetry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLErule_failure_telemetry_id_seq OWNER TO openchs;

--
-- Name: rule_failure_telemetry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCErule_failure_telemetry_id_seq OWNED BY rule_failure_telemetry.id;


--
-- Name: rule_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLErule_id_seq OWNER TO openchs;

--
-- Name: rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCErule_id_seq OWNED BY rule.id;


--
-- Name: schema_version; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE schema_version (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


-- ALTER TABLEschema_version OWNER TO openchs;

--
-- Name: subject_type; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE subject_type (
    id integer NOT NULL,
    uuid character varying(255),
    name character varying(255) NOT NULL,
    organisation_id bigint NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    audit_id bigint NOT NULL,
    version integer DEFAULT 1,
    is_group boolean DEFAULT false NOT NULL,
    is_household boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    type character varying(255)
);


-- ALTER TABLEsubject_type OWNER TO openchs;

--
-- Name: subject_type_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE subject_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEsubject_type_id_seq OWNER TO openchs;

--
-- Name: subject_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEsubject_type_id_seq OWNED BY subject_type.id;


--
-- Name: sync_telemetry; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE sync_telemetry (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    user_id integer NOT NULL,
    organisation_id bigint NOT NULL,
    version integer DEFAULT 1,
    sync_status character varying(255) NOT NULL,
    sync_start_time timestamp with time zone NOT NULL,
    sync_end_time timestamp with time zone,
    entity_status jsonb,
    device_name character varying(255),
    android_version character varying(255),
    app_version character varying(255)
);


-- ALTER TABLEsync_telemetry OWNER TO openchs;

--
-- Name: sync_telemetry_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE sync_telemetry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEsync_telemetry_id_seq OWNER TO openchs;

--
-- Name: sync_telemetry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEsync_telemetry_id_seq OWNED BY sync_telemetry.id;


--
-- Name: title_lineage_locations_view; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW title_lineage_locations_view AS
 SELECT al.id AS lowestpoint_id,
    string_agg((alevel_in_lineage.title)::text, ', '::text ORDER BY lineage.level) AS title_lineage
   FROM ((address_level al
     JOIN LATERAL regexp_split_to_table((al.lineage)::text, '[.]'::text) WITH ORDINALITY lineage(point_id, level) ON (true))
     JOIN address_level alevel_in_lineage ON ((alevel_in_lineage.id = (lineage.point_id)::integer)))
  GROUP BY al.id;


-- ALTER TABLEtitle_lineage_locations_view OWNER TO openchs;

--
-- Name: translation; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE translation (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    organisation_id bigint NOT NULL,
    audit_id bigint NOT NULL,
    version integer DEFAULT 1,
    translation_json jsonb NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    language character varying(255)
);


-- ALTER TABLEtranslation OWNER TO openchs;

--
-- Name: translation_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE translation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEtranslation_id_seq OWNER TO openchs;

--
-- Name: translation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEtranslation_id_seq OWNED BY translation.id;


--
-- Name: user_facility_mapping; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE user_facility_mapping (
    id integer NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    audit_id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    organisation_id bigint NOT NULL,
    facility_id bigint NOT NULL,
    user_id bigint NOT NULL
);


-- ALTER TABLEuser_facility_mapping OWNER TO openchs;

--
-- Name: user_facility_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE user_facility_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEuser_facility_mapping_id_seq OWNER TO openchs;

--
-- Name: user_facility_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEuser_facility_mapping_id_seq OWNED BY user_facility_mapping.id;


--
-- Name: user_group; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE user_group (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    version integer,
    organisation_id integer NOT NULL,
    audit_id integer
);


-- ALTER TABLEuser_group OWNER TO openchs;

--
-- Name: user_group_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE user_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEuser_group_id_seq OWNER TO openchs;

--
-- Name: user_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEuser_group_id_seq OWNED BY user_group.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE users (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    organisation_id integer,
    created_by_id bigint DEFAULT 1 NOT NULL,
    last_modified_by_id bigint DEFAULT 1 NOT NULL,
    created_date_time timestamp with time zone DEFAULT now() NOT NULL,
    last_modified_date_time timestamp with time zone DEFAULT now() NOT NULL,
    is_voided boolean DEFAULT false NOT NULL,
    catchment_id integer,
    is_org_admin boolean DEFAULT false NOT NULL,
    operating_individual_scope character varying(255) NOT NULL,
    settings jsonb,
    email character varying(320),
    phone_number character varying(32),
    disabled_in_cognito boolean DEFAULT false,
    name character varying(255),
    CONSTRAINT users_check CHECK ((((operating_individual_scope)::text <> 'ByCatchment'::text) OR (catchment_id IS NOT NULL)))
);


-- ALTER TABLEusers OWNER TO openchs;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEusers_id_seq OWNER TO openchs;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEusers_id_seq OWNED BY users.id;


--
-- Name: video; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE video (
    id integer NOT NULL,
    version integer DEFAULT 1,
    audit_id bigint NOT NULL,
    uuid character varying(255),
    organisation_id bigint NOT NULL,
    title character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL,
    description character varying(255),
    duration integer,
    is_voided boolean DEFAULT false NOT NULL
);


-- ALTER TABLEvideo OWNER TO openchs;

--
-- Name: video_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE video_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEvideo_id_seq OWNER TO openchs;

--
-- Name: video_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEvideo_id_seq OWNED BY video.id;


--
-- Name: video_telemetric; Type: TABLE; Schema: public; Owner: openchs
--

CREATE TABLE video_telemetric (
    id integer NOT NULL,
    uuid character varying(255),
    video_start_time double  NOT NULL,
    video_end_time double  NOT NULL,
    player_open_time timestamp with time zone NOT NULL,
    player_close_time timestamp with time zone NOT NULL,
    video_id integer NOT NULL,
    user_id integer NOT NULL,
    created_datetime timestamp with time zone NOT NULL,
    organisation_id integer NOT NULL,
    is_voided boolean DEFAULT false NOT NULL
);


-- ALTER TABLEvideo_telemetric OWNER TO openchs;

--
-- Name: video_telemetric_id_seq; Type: SEQUENCE; Schema: public; Owner: openchs
--

CREATE SEQUENCE video_telemetric_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ALTER TABLEvideo_telemetric_id_seq OWNER TO openchs;

--
-- Name: video_telemetric_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: openchs
--

-- ALTER SEQUENCEvideo_telemetric_id_seq OWNED BY video_telemetric.id;


--
-- Name: virtual_catchment_address_mapping_table; Type: VIEW; Schema: public; Owner: openchs
--

CREATE VIEW virtual_catchment_address_mapping_table AS
 WITH RECURSIVE intermediary_table AS (
         SELECT c.id AS cid,
            al1.id AS aid,
            al2.id AS parent_id
           FROM ((((address_level al1
             LEFT JOIN location_location_mapping llm ON ((al1.id = llm.location_id)))
             LEFT JOIN address_level al2 ON ((llm.parent_location_id = al2.id)))
             LEFT JOIN catchment_address_mapping cam ON ((cam.addresslevel_id = al1.id)))
             LEFT JOIN catchment c ON ((cam.catchment_id = c.id)))
        ), vt AS (
         SELECT intermediary_table.cid,
            intermediary_table.aid,
            intermediary_table.parent_id
           FROM intermediary_table
        UNION ALL
         SELECT vt_1.cid,
            it.aid,
            it.parent_id
           FROM intermediary_table it,
            vt vt_1
          WHERE (vt_1.aid = it.parent_id)
        )
 SELECT row_number() OVER () AS id,
    vt.cid AS catchment_id,
    vt.aid AS addresslevel_id
   FROM vt
  WHERE (vt.cid IS NOT NULL)
  GROUP BY vt.cid, vt.aid;


-- ALTER TABLEvirtual_catchment_address_mapping_table OWNER TO openchs;

--
-- Name: account id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY account ALTER COLUMN id SET DEFAULT nextval('account_id_seq'::regclass);


--
-- Name: account_admin id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY account_admin ALTER COLUMN id SET DEFAULT nextval('account_admin_id_seq'::regclass);


--
-- Name: address_level id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level ALTER COLUMN id SET DEFAULT nextval('address_level_id_seq'::regclass);


--
-- Name: address_level_type id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level_type ALTER COLUMN id SET DEFAULT nextval('address_level_type_id_seq'::regclass);


--
-- Name: audit id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY audit ALTER COLUMN id SET DEFAULT nextval('audit_id_seq'::regclass);


--
-- Name: catchment id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY catchment ALTER COLUMN id SET DEFAULT nextval('catchment_id_seq'::regclass);


--
-- Name: catchment_address_mapping id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY catchment_address_mapping ALTER COLUMN id SET DEFAULT nextval('catchment_address_mapping_id_seq'::regclass);


--
-- Name: checklist id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist ALTER COLUMN id SET DEFAULT nextval('checklist_id_seq'::regclass);


--
-- Name: checklist_detail id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_detail ALTER COLUMN id SET DEFAULT nextval('checklist_detail_id_seq'::regclass);


--
-- Name: checklist_item id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item ALTER COLUMN id SET DEFAULT nextval('checklist_item_id_seq'::regclass);


--
-- Name: checklist_item_detail id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item_detail ALTER COLUMN id SET DEFAULT nextval('checklist_item_detail_id_seq'::regclass);


--
-- Name: concept id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept ALTER COLUMN id SET DEFAULT nextval('concept_id_seq'::regclass);


--
-- Name: concept_answer id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept_answer ALTER COLUMN id SET DEFAULT nextval('concept_answer_id_seq'::regclass);


--
-- Name: deps_saved_ddl deps_id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY deps_saved_ddl ALTER COLUMN deps_id SET DEFAULT nextval('deps_saved_ddl_deps_id_seq'::regclass);


--
-- Name: encounter id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter ALTER COLUMN id SET DEFAULT nextval('encounter_id_seq'::regclass);


--
-- Name: encounter_type id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter_type ALTER COLUMN id SET DEFAULT nextval('encounter_type_id_seq'::regclass);


--
-- Name: facility id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY facility ALTER COLUMN id SET DEFAULT nextval('facility_id_seq'::regclass);


--
-- Name: form id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form ALTER COLUMN id SET DEFAULT nextval('form_id_seq'::regclass);


--
-- Name: form_element id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element ALTER COLUMN id SET DEFAULT nextval('form_element_id_seq'::regclass);


--
-- Name: form_element_group id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element_group ALTER COLUMN id SET DEFAULT nextval('form_element_group_id_seq'::regclass);


--
-- Name: form_mapping id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_mapping ALTER COLUMN id SET DEFAULT nextval('form_mapping_id_seq'::regclass);


--
-- Name: gender id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY gender ALTER COLUMN id SET DEFAULT nextval('gender_id_seq'::regclass);


--
-- Name: group_privilege id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_privilege ALTER COLUMN id SET DEFAULT nextval('group_privilege_id_seq'::regclass);


--
-- Name: group_role id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_role ALTER COLUMN id SET DEFAULT nextval('group_role_id_seq'::regclass);


--
-- Name: group_subject id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_subject ALTER COLUMN id SET DEFAULT nextval('group_subject_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: identifier_assignment id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_assignment ALTER COLUMN id SET DEFAULT nextval('identifier_assignment_id_seq'::regclass);


--
-- Name: identifier_source id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_source ALTER COLUMN id SET DEFAULT nextval('identifier_source_id_seq'::regclass);


--
-- Name: identifier_user_assignment id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_user_assignment ALTER COLUMN id SET DEFAULT nextval('identifier_user_assignment_id_seq'::regclass);


--
-- Name: individual id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual ALTER COLUMN id SET DEFAULT nextval('individual_id_seq'::regclass);


--
-- Name: individual_relation id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relation ALTER COLUMN id SET DEFAULT nextval('individual_relation_id_seq'::regclass);


--
-- Name: individual_relation_gender_mapping id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relation_gender_mapping ALTER COLUMN id SET DEFAULT nextval('individual_relation_gender_mapping_id_seq'::regclass);


--
-- Name: individual_relationship id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relationship ALTER COLUMN id SET DEFAULT nextval('individual_relationship_id_seq'::regclass);


--
-- Name: individual_relationship_type id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relationship_type ALTER COLUMN id SET DEFAULT nextval('individual_relationship_type_id_seq'::regclass);


--
-- Name: individual_relative id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relative ALTER COLUMN id SET DEFAULT nextval('individual_relative_id_seq'::regclass);


--
-- Name: location_location_mapping id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY location_location_mapping ALTER COLUMN id SET DEFAULT nextval('location_location_mapping_id_seq'::regclass);


--
-- Name: non_applicable_form_element id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY non_applicable_form_element ALTER COLUMN id SET DEFAULT nextval('non_applicable_form_element_id_seq'::regclass);


--
-- Name: operational_encounter_type id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_encounter_type ALTER COLUMN id SET DEFAULT nextval('operational_encounter_type_id_seq'::regclass);


--
-- Name: operational_program id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_program ALTER COLUMN id SET DEFAULT nextval('operational_program_id_seq'::regclass);


--
-- Name: operational_subject_type id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_subject_type ALTER COLUMN id SET DEFAULT nextval('operational_subject_type_id_seq'::regclass);


--
-- Name: organisation id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation ALTER COLUMN id SET DEFAULT nextval('organisation_id_seq'::regclass);


--
-- Name: organisation_config id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_config ALTER COLUMN id SET DEFAULT nextval('organisation_config_id_seq'::regclass);


--
-- Name: organisation_group id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_group ALTER COLUMN id SET DEFAULT nextval('organisation_group_id_seq'::regclass);


--
-- Name: organisation_group_organisation id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_group_organisation ALTER COLUMN id SET DEFAULT nextval('organisation_group_organisation_id_seq'::regclass);


--
-- Name: platform_translation id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY platform_translation ALTER COLUMN id SET DEFAULT nextval('platform_translation_id_seq'::regclass);


--
-- Name: privilege id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY privilege ALTER COLUMN id SET DEFAULT nextval('privilege_id_seq'::regclass);


--
-- Name: program id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program ALTER COLUMN id SET DEFAULT nextval('program_id_seq'::regclass);


--
-- Name: program_encounter id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_encounter ALTER COLUMN id SET DEFAULT nextval('program_encounter_id_seq'::regclass);


--
-- Name: program_enrolment id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_enrolment ALTER COLUMN id SET DEFAULT nextval('program_enrolment_id_seq'::regclass);


--
-- Name: program_organisation_config id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_organisation_config ALTER COLUMN id SET DEFAULT nextval('program_organisation_config_id_seq'::regclass);


--
-- Name: program_organisation_config_at_risk_concept id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_organisation_config_at_risk_concept ALTER COLUMN id SET DEFAULT nextval('program_organisation_config_at_risk_concept_id_seq'::regclass);


--
-- Name: program_outcome id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_outcome ALTER COLUMN id SET DEFAULT nextval('program_outcome_id_seq'::regclass);


--
-- Name: rule id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule ALTER COLUMN id SET DEFAULT nextval('rule_id_seq'::regclass);


--
-- Name: rule_dependency id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule_dependency ALTER COLUMN id SET DEFAULT nextval('rule_dependency_id_seq'::regclass);


--
-- Name: rule_failure_log id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule_failure_log ALTER COLUMN id SET DEFAULT nextval('rule_failure_log_id_seq'::regclass);


--
-- Name: rule_failure_telemetry id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule_failure_telemetry ALTER COLUMN id SET DEFAULT nextval('rule_failure_telemetry_id_seq'::regclass);


--
-- Name: subject_type id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY subject_type ALTER COLUMN id SET DEFAULT nextval('subject_type_id_seq'::regclass);


--
-- Name: sync_telemetry id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY sync_telemetry ALTER COLUMN id SET DEFAULT nextval('sync_telemetry_id_seq'::regclass);


--
-- Name: translation id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY translation ALTER COLUMN id SET DEFAULT nextval('translation_id_seq'::regclass);


--
-- Name: user_facility_mapping id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY user_facility_mapping ALTER COLUMN id SET DEFAULT nextval('user_facility_mapping_id_seq'::regclass);


--
-- Name: user_group id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY user_group ALTER COLUMN id SET DEFAULT nextval('user_group_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: video id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY video ALTER COLUMN id SET DEFAULT nextval('video_id_seq'::regclass);


--
-- Name: video_telemetric id; Type: DEFAULT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY video_telemetric ALTER COLUMN id SET DEFAULT nextval('video_telemetric_id_seq'::regclass);


--
-- Name: account_admin account_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY account_admin
--     -- ADD CONSTRAINTaccount_admin_pkey PRIMARY KEY (id);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY account
--     -- ADD CONSTRAINTaccount_pkey PRIMARY KEY (id);


--
-- Name: address_level address_level_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level
--     -- ADD CONSTRAINTaddress_level_pkey PRIMARY KEY (id);


--
-- Name: address_level_type address_level_type_name_organisation_id_unique; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level_type
--     -- ADD CONSTRAINTaddress_level_type_name_organisation_id_unique UNIQUE (name, organisation_id);


--
-- Name: address_level_type address_level_type_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level_type
--     -- ADD CONSTRAINTaddress_level_type_pkey PRIMARY KEY (id);


--
-- Name: address_level address_level_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level
--     -- ADD CONSTRAINTaddress_level_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY audit
    -- ADD CONSTRAINTaudit_pkey PRIMARY KEY (id);


--
-- Name: batch_job_execution_context batch_job_execution_context_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY batch_job_execution_context
    -- ADD CONSTRAINTbatch_job_execution_context_pkey PRIMARY KEY (job_execution_id);


--
-- Name: batch_job_execution batch_job_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY batch_job_execution
    -- ADD CONSTRAINTbatch_job_execution_pkey PRIMARY KEY (job_execution_id);


--
-- Name: batch_job_instance batch_job_instance_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY batch_job_instance
    -- ADD CONSTRAINTbatch_job_instance_pkey PRIMARY KEY (job_instance_id);


--
-- Name: batch_step_execution_context batch_step_execution_context_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY batch_step_execution_context
    -- ADD CONSTRAINTbatch_step_execution_context_pkey PRIMARY KEY (step_execution_id);


--
-- Name: batch_step_execution batch_step_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY batch_step_execution
    -- ADD CONSTRAINTbatch_step_execution_pkey PRIMARY KEY (step_execution_id);


--
-- Name: catchment_address_mapping catchment_address_mapping_catchment_id_address_level_id_unique; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY catchment_address_mapping
    -- ADD CONSTRAINTcatchment_address_mapping_catchment_id_address_level_id_unique UNIQUE (catchment_id, addresslevel_id);


--
-- Name: catchment_address_mapping catchment_address_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY catchment_address_mapping
    -- ADD CONSTRAINTcatchment_address_mapping_pkey PRIMARY KEY (id);


--
-- Name: catchment catchment_name_organisation_id_unique; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY catchment
    -- ADD CONSTRAINTcatchment_name_organisation_id_unique UNIQUE (name, organisation_id);


--
-- Name: catchment catchment_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY catchment
    -- ADD CONSTRAINTcatchment_pkey PRIMARY KEY (id);


--
-- Name: catchment catchment_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY catchment
    -- ADD CONSTRAINTcatchment_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: checklist checklist_checklist_detail_id_program_enrolment_id_unique; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist
    -- ADD CONSTRAINTchecklist_checklist_detail_id_program_enrolment_id_unique UNIQUE (checklist_detail_id, program_enrolment_id);


--
-- Name: checklist_detail checklist_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_detail
    -- ADD CONSTRAINTchecklist_detail_pkey PRIMARY KEY (id);


--
-- Name: checklist_detail checklist_detail_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_detail
    -- ADD CONSTRAINTchecklist_detail_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: checklist_item_detail checklist_item_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item_detail
    -- ADD CONSTRAINTchecklist_item_detail_pkey PRIMARY KEY (id);


--
-- Name: checklist_item_detail checklist_item_detail_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item_detail
    -- ADD CONSTRAINTchecklist_item_detail_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: checklist_item checklist_item_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item
    -- ADD CONSTRAINTchecklist_item_pkey PRIMARY KEY (id);


--
-- Name: checklist_item checklist_item_uuid_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item
    -- ADD CONSTRAINTchecklist_item_uuid_key UNIQUE (uuid);


--
-- Name: checklist checklist_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist
    -- ADD CONSTRAINTchecklist_pkey PRIMARY KEY (id);


--
-- Name: checklist checklist_uuid_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist
    -- ADD CONSTRAINTchecklist_uuid_key UNIQUE (uuid);


--
-- Name: concept_answer concept_answer_concept_id_answer_concept_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept_answer
    -- ADD CONSTRAINTconcept_answer_concept_id_answer_concept_id_key UNIQUE (concept_id, answer_concept_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: concept_answer concept_answer_concept_id_answer_concept_id_organisation_id_uni; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept_answer
    -- ADD CONSTRAINTconcept_answer_concept_id_answer_concept_id_organisation_id_uni UNIQUE (concept_id, answer_concept_id, organisation_id);


--
-- Name: concept_answer concept_answer_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept_answer
    -- ADD CONSTRAINTconcept_answer_pkey PRIMARY KEY (id);


--
-- Name: concept_answer concept_answer_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept_answer
    -- ADD CONSTRAINTconcept_answer_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: concept concept_name_orgid; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept
    -- ADD CONSTRAINTconcept_name_orgid UNIQUE (name, organisation_id);


--
-- Name: concept concept_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept
    -- ADD CONSTRAINTconcept_pkey PRIMARY KEY (id);


--
-- Name: concept concept_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept
    -- ADD CONSTRAINTconcept_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: deps_saved_ddl deps_saved_ddl_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY deps_saved_ddl
    -- ADD CONSTRAINTdeps_saved_ddl_pkey PRIMARY KEY (deps_id);


--
-- Name: encounter encounter_legacy_id_organisation_id_uniq_idx; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter
    -- ADD CONSTRAINTencounter_legacy_id_organisation_id_uniq_idx UNIQUE (legacy_id, organisation_id);


--
-- Name: encounter encounter_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter
    -- ADD CONSTRAINTencounter_pkey PRIMARY KEY (id);


--
-- Name: encounter_type encounter_type_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter_type
    -- ADD CONSTRAINTencounter_type_pkey PRIMARY KEY (id);


--
-- Name: encounter_type encounter_type_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter_type
    -- ADD CONSTRAINTencounter_type_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: encounter encounter_uuid_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter
    -- ADD CONSTRAINTencounter_uuid_key UNIQUE (uuid);


--
-- Name: facility facility_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY facility
    -- ADD CONSTRAINTfacility_pkey PRIMARY KEY (id);


--
-- Name: form_element form_element_form_element_group_id_display_order_organisati_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element
    -- ADD CONSTRAINTform_element_form_element_group_id_display_order_organisati_key UNIQUE (form_element_group_id, display_order, organisation_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: form_element_group form_element_group_form_id_display_order_organisation_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element_group
    -- ADD CONSTRAINTform_element_group_form_id_display_order_organisation_id_key UNIQUE (form_id, display_order, organisation_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: form_element_group form_element_group_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element_group
    -- ADD CONSTRAINTform_element_group_pkey PRIMARY KEY (id);


--
-- Name: form_element_group form_element_group_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element_group
    -- ADD CONSTRAINTform_element_group_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: form_element form_element_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element
    -- ADD CONSTRAINTform_element_pkey PRIMARY KEY (id);


--
-- Name: form_element form_element_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element
    -- ADD CONSTRAINTform_element_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: form_mapping form_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_mapping
    -- ADD CONSTRAINTform_mapping_pkey PRIMARY KEY (id);


--
-- Name: form_mapping form_mapping_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_mapping
    -- ADD CONSTRAINTform_mapping_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: form form_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form
    -- ADD CONSTRAINTform_pkey PRIMARY KEY (id);


--
-- Name: form form_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form
    -- ADD CONSTRAINTform_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: gender gender_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY gender
    -- ADD CONSTRAINTgender_pkey PRIMARY KEY (id);


--
-- Name: gender gender_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY gender
    -- ADD CONSTRAINTgender_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: group_privilege group_privilege_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_privilege
    -- ADD CONSTRAINTgroup_privilege_pkey PRIMARY KEY (id);


--
-- Name: group_role group_role_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_role
    -- ADD CONSTRAINTgroup_role_pkey PRIMARY KEY (id);


--
-- Name: group_subject group_subject_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_subject
    -- ADD CONSTRAINTgroup_subject_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY groups
    -- ADD CONSTRAINTgroups_pkey PRIMARY KEY (id);


--
-- Name: identifier_assignment identifier_assignment_identifier_source_id_identifier_organ_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_assignment
    -- ADD CONSTRAINTidentifier_assignment_identifier_source_id_identifier_organ_key UNIQUE (identifier_source_id, identifier, organisation_id);


--
-- Name: identifier_assignment identifier_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_assignment
    -- ADD CONSTRAINTidentifier_assignment_pkey PRIMARY KEY (id);


--
-- Name: identifier_assignment identifier_assignment_uuid_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_assignment
    -- ADD CONSTRAINTidentifier_assignment_uuid_key UNIQUE (uuid);


--
-- Name: identifier_source identifier_source_name_organisation_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_source
    -- ADD CONSTRAINTidentifier_source_name_organisation_id_key UNIQUE (name, organisation_id);


--
-- Name: identifier_source identifier_source_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_source
    -- ADD CONSTRAINTidentifier_source_pkey PRIMARY KEY (id);


--
-- Name: identifier_source identifier_source_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_source
    -- ADD CONSTRAINTidentifier_source_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: identifier_user_assignment identifier_user_assignment_identifier_source_id_assigned_to_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_user_assignment
    -- ADD CONSTRAINTidentifier_user_assignment_identifier_source_id_assigned_to_key UNIQUE (identifier_source_id, assigned_to_user_id, identifier_start);


--
-- Name: identifier_user_assignment identifier_user_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_user_assignment
    -- ADD CONSTRAINTidentifier_user_assignment_pkey PRIMARY KEY (id);


--
-- Name: identifier_user_assignment identifier_user_assignment_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_user_assignment
    -- ADD CONSTRAINTidentifier_user_assignment_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: individual individual_legacy_id_organisation_id_uniq_idx; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual
    -- ADD CONSTRAINTindividual_legacy_id_organisation_id_uniq_idx UNIQUE (legacy_id, organisation_id);


--
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual
    -- ADD CONSTRAINTindividual_pkey PRIMARY KEY (id);


--
-- Name: individual_relation_gender_mapping individual_relation_gender_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relation_gender_mapping
    -- ADD CONSTRAINTindividual_relation_gender_mapping_pkey PRIMARY KEY (id);


--
-- Name: individual_relation individual_relation_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relation
    -- ADD CONSTRAINTindividual_relation_pkey PRIMARY KEY (id);


--
-- Name: individual_relationship individual_relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relationship
    -- ADD CONSTRAINTindividual_relationship_pkey PRIMARY KEY (id);


--
-- Name: individual_relationship_type individual_relationship_type_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relationship_type
    -- ADD CONSTRAINTindividual_relationship_type_pkey PRIMARY KEY (id);


--
-- Name: individual_relative individual_relative_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relative
    -- ADD CONSTRAINTindividual_relative_pkey PRIMARY KEY (id);


--
-- Name: individual individual_uuid_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual
    -- ADD CONSTRAINTindividual_uuid_key UNIQUE (uuid);


--
-- Name: batch_job_instance job_inst_un; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY batch_job_instance
    -- ADD CONSTRAINTjob_inst_un UNIQUE (job_name, job_key);


--
-- Name: location_location_mapping location_location_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY location_location_mapping
    -- ADD CONSTRAINTlocation_location_mapping_pkey PRIMARY KEY (id);


--
-- Name: non_applicable_form_element non_applicable_form_element_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY non_applicable_form_element
    -- ADD CONSTRAINTnon_applicable_form_element_pkey PRIMARY KEY (id);


--
-- Name: operational_encounter_type operational_encounter_type_encounter_type_organisation_id_uniqu; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_encounter_type
    -- ADD CONSTRAINToperational_encounter_type_encounter_type_organisation_id_uniqu UNIQUE (encounter_type_id, organisation_id);


--
-- Name: operational_encounter_type operational_encounter_type_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_encounter_type
    -- ADD CONSTRAINToperational_encounter_type_pkey PRIMARY KEY (id);


--
-- Name: operational_program operational_program_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_program
    -- ADD CONSTRAINToperational_program_pkey PRIMARY KEY (id);


--
-- Name: operational_program operational_program_program_id_organisation_id_unique; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_program
    -- ADD CONSTRAINToperational_program_program_id_organisation_id_unique UNIQUE (program_id, organisation_id);


--
-- Name: operational_subject_type operational_subject_type_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_subject_type
    -- ADD CONSTRAINToperational_subject_type_pkey PRIMARY KEY (id);


--
-- Name: operational_subject_type operational_subject_type_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_subject_type
    -- ADD CONSTRAINToperational_subject_type_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: organisation_config organisation_config_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_config
    -- ADD CONSTRAINTorganisation_config_pkey PRIMARY KEY (id);


--
-- Name: organisation_config organisation_config_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_config
    -- ADD CONSTRAINTorganisation_config_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: organisation organisation_db_user_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation
    -- ADD CONSTRAINTorganisation_db_user_key UNIQUE (db_user);


--
-- Name: organisation_group_organisation organisation_group_organisation_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_group_organisation
    -- ADD CONSTRAINTorganisation_group_organisation_pkey PRIMARY KEY (id);


--
-- Name: organisation_group organisation_group_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_group
    -- ADD CONSTRAINTorganisation_group_pkey PRIMARY KEY (id);


--
-- Name: organisation organisation_media_directory_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation
    -- ADD CONSTRAINTorganisation_media_directory_key UNIQUE (media_directory);


--
-- Name: organisation organisation_name_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation
    -- ADD CONSTRAINTorganisation_name_key UNIQUE (name);


--
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation
    -- ADD CONSTRAINTorganisation_pkey PRIMARY KEY (id);


--
-- Name: organisation organisation_uuid_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation
    -- ADD CONSTRAINTorganisation_uuid_key UNIQUE (uuid);


--
-- Name: platform_translation platform_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY platform_translation
    -- ADD CONSTRAINTplatform_translation_pkey PRIMARY KEY (id);


--
-- Name: privilege privilege_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY privilege
    -- ADD CONSTRAINTprivilege_pkey PRIMARY KEY (id);


--
-- Name: program_encounter program_encounter_legacy_id_organisation_id_uniq_idx; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_encounter
    -- ADD CONSTRAINTprogram_encounter_legacy_id_organisation_id_uniq_idx UNIQUE (legacy_id, organisation_id);


--
-- Name: program_encounter program_encounter_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_encounter
    -- ADD CONSTRAINTprogram_encounter_pkey PRIMARY KEY (id);


--
-- Name: program_encounter program_encounter_uuid_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_encounter
    -- ADD CONSTRAINTprogram_encounter_uuid_key UNIQUE (uuid);


--
-- Name: program_enrolment program_enrolment_legacy_id_organisation_id_uniq_idx; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_enrolment
    -- ADD CONSTRAINTprogram_enrolment_legacy_id_organisation_id_uniq_idx UNIQUE (legacy_id, organisation_id);


--
-- Name: program_enrolment program_enrolment_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_enrolment
    -- ADD CONSTRAINTprogram_enrolment_pkey PRIMARY KEY (id);


--
-- Name: program_enrolment program_enrolment_uuid_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_enrolment
    -- ADD CONSTRAINTprogram_enrolment_uuid_key UNIQUE (uuid);


--
-- Name: program_organisation_config_at_risk_concept program_organisation_config_at_risk_concept_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_organisation_config_at_risk_concept
    -- ADD CONSTRAINTprogram_organisation_config_at_risk_concept_pkey PRIMARY KEY (id);


--
-- Name: program_organisation_config program_organisation_config_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_organisation_config
    -- ADD CONSTRAINTprogram_organisation_config_pkey PRIMARY KEY (id);


--
-- Name: program_organisation_config program_organisation_config_uuid_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_organisation_config
    -- ADD CONSTRAINTprogram_organisation_config_uuid_key UNIQUE (uuid);


--
-- Name: program_organisation_config program_organisation_unique_constraint; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_organisation_config
    -- ADD CONSTRAINTprogram_organisation_unique_constraint UNIQUE (program_id, organisation_id);


--
-- Name: program_outcome program_outcome_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_outcome
    -- ADD CONSTRAINTprogram_outcome_pkey PRIMARY KEY (id);


--
-- Name: program_outcome program_outcome_uuid_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_outcome
    -- ADD CONSTRAINTprogram_outcome_uuid_key UNIQUE (uuid);


--
-- Name: program program_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program
    -- ADD CONSTRAINTprogram_pkey PRIMARY KEY (id);


--
-- Name: program program_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program
    -- ADD CONSTRAINTprogram_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: rule_dependency rule_dependency_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule_dependency
    -- ADD CONSTRAINTrule_dependency_pkey PRIMARY KEY (id);


--
-- Name: rule_dependency rule_dependency_uuid_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule_dependency
    -- ADD CONSTRAINTrule_dependency_uuid_key UNIQUE (uuid);


--
-- Name: rule_failure_log rule_failure_log_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule_failure_log
    -- ADD CONSTRAINTrule_failure_log_pkey PRIMARY KEY (id);


--
-- Name: rule_failure_telemetry rule_failure_telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule_failure_telemetry
    -- ADD CONSTRAINTrule_failure_telemetry_pkey PRIMARY KEY (id);


--
-- Name: rule rule_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule
    -- ADD CONSTRAINTrule_pkey PRIMARY KEY (id);


--
-- Name: rule rule_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule
    -- ADD CONSTRAINTrule_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY schema_version
    -- ADD CONSTRAINTschema_version_pk PRIMARY KEY (installed_rank);


--
-- Name: subject_type subject_type_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY subject_type
    -- ADD CONSTRAINTsubject_type_pkey PRIMARY KEY (id);


--
-- Name: sync_telemetry sync_telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY sync_telemetry
    -- ADD CONSTRAINTsync_telemetry_pkey PRIMARY KEY (id);


--
-- Name: translation translation_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY translation
    -- ADD CONSTRAINTtranslation_pkey PRIMARY KEY (id);


--
-- Name: translation translation_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY translation
    -- ADD CONSTRAINTtranslation_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: rule unique_fn_rule_name; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule
    -- ADD CONSTRAINTunique_fn_rule_name UNIQUE (organisation_id, fn_name);


--
-- Name: address_level unique_name_per_level; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level
    -- ADD CONSTRAINTunique_name_per_level UNIQUE (title, type_id, parent_id, organisation_id);


--
-- Name: rule unique_rule_name; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule
    -- ADD CONSTRAINTunique_rule_name UNIQUE (organisation_id, name);


--
-- Name: user_facility_mapping user_facility_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY user_facility_mapping
    -- ADD CONSTRAINTuser_facility_mapping_pkey PRIMARY KEY (id);


--
-- Name: user_group user_group_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY user_group
    -- ADD CONSTRAINTuser_group_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY users
    -- ADD CONSTRAINTusers_pkey PRIMARY KEY (id);


--
-- Name: users users_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY users
    -- ADD CONSTRAINTusers_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: video video_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY video
    -- ADD CONSTRAINTvideo_pkey PRIMARY KEY (id);


--
-- Name: video_telemetric video_telemetric_pkey; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY video_telemetric
    -- ADD CONSTRAINTvideo_telemetric_pkey PRIMARY KEY (id);


--
-- Name: video video_uuid_org_id_key; Type: CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY video
    -- ADD CONSTRAINTvideo_uuid_org_id_key UNIQUE (uuid, organisation_id);


--
-- Name: address_level_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXaddress_level_organisation_id__index ON address_level USING btree (organisation_id);


--
-- Name: address_level_type_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXaddress_level_type_organisation_id__index ON address_level_type USING btree (organisation_id);


--
-- Name: catchment_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXcatchment_organisation_id__index ON catchment USING btree (organisation_id);


--
-- Name: checklist_checklist_detail_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_checklist_detail_id_index ON checklist USING btree (checklist_detail_id);


--
-- Name: checklist_detail_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_detail_organisation_id__index ON checklist_detail USING btree (organisation_id);


--
-- Name: checklist_item_checklist_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_item_checklist_id_index ON checklist_item USING btree (checklist_id);


--
-- Name: checklist_item_checklist_item_detail_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_item_checklist_item_detail_id_index ON checklist_item USING btree (checklist_item_detail_id);


--
-- Name: checklist_item_detail_checklist_detail_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_item_detail_checklist_detail_id_index ON checklist_item_detail USING btree (checklist_detail_id);


--
-- Name: checklist_item_detail_concept_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_item_detail_concept_id_index ON checklist_item_detail USING btree (concept_id);


--
-- Name: checklist_item_detail_dependent_on_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_item_detail_dependent_on_index ON checklist_item_detail USING btree (dependent_on);


--
-- Name: checklist_item_detail_form_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_item_detail_form_id_index ON checklist_item_detail USING btree (form_id);


--
-- Name: checklist_item_detail_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_item_detail_organisation_id__index ON checklist_item_detail USING btree (organisation_id);


--
-- Name: checklist_item_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_item_organisation_id__index ON checklist_item USING btree (organisation_id);


--
-- Name: checklist_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_organisation_id__index ON checklist USING btree (organisation_id);


--
-- Name: checklist_program_enrolment_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXchecklist_program_enrolment_id_index ON checklist USING btree (program_enrolment_id);


--
-- Name: concept_answer_answer_concept_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXconcept_answer_answer_concept_id_index ON concept_answer USING btree (answer_concept_id);


--
-- Name: concept_answer_concept_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXconcept_answer_concept_id_index ON concept_answer USING btree (concept_id);


--
-- Name: concept_answer_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXconcept_answer_organisation_id__index ON concept_answer USING btree (organisation_id);


--
-- Name: concept_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXconcept_organisation_id__index ON concept USING btree (organisation_id);


--
-- Name: encounter_encounter_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXencounter_encounter_type_id_index ON encounter USING btree (encounter_type_id);


--
-- Name: encounter_individual_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXencounter_individual_id_index ON encounter USING btree (individual_id);


--
-- Name: encounter_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXencounter_organisation_id__index ON encounter USING btree (organisation_id);


--
-- Name: encounter_type_concept_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXencounter_type_concept_id_index ON encounter_type USING btree (concept_id);


--
-- Name: encounter_type_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXencounter_type_organisation_id__index ON encounter_type USING btree (organisation_id);


--
-- Name: facility_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXfacility_organisation_id__index ON facility USING btree (organisation_id);


--
-- Name: form_element_concept_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXform_element_concept_id_index ON form_element USING btree (concept_id);


--
-- Name: form_element_form_element_group_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXform_element_form_element_group_id_index ON form_element USING btree (form_element_group_id);


--
-- Name: form_element_group_form_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXform_element_group_form_id_index ON form_element_group USING btree (form_id);


--
-- Name: form_element_group_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXform_element_group_organisation_id__index ON form_element_group USING btree (organisation_id);


--
-- Name: form_element_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXform_element_organisation_id__index ON form_element USING btree (organisation_id);


--
-- Name: form_mapping_form_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXform_mapping_form_id_index ON form_mapping USING btree (form_id);


--
-- Name: form_mapping_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXform_mapping_organisation_id__index ON form_mapping USING btree (organisation_id);


--
-- Name: form_mapping_subject_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXform_mapping_subject_type_id_index ON form_mapping USING btree (subject_type_id);


--
-- Name: form_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXform_organisation_id__index ON form USING btree (organisation_id);


--
-- Name: gender_concept_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgender_concept_id_index ON gender USING btree (concept_id);


--
-- Name: gender_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgender_organisation_id__index ON gender USING btree (organisation_id);


--
-- Name: group_privilege_checklist_detail_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgroup_privilege_checklist_detail_id_index ON group_privilege USING btree (checklist_detail_id);


--
-- Name: group_privilege_encounter_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgroup_privilege_encounter_type_id_index ON group_privilege USING btree (encounter_type_id);


--
-- Name: group_privilege_group_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgroup_privilege_group_id_index ON group_privilege USING btree (group_id);


--
-- Name: group_privilege_program_encounter_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgroup_privilege_program_encounter_type_id_index ON group_privilege USING btree (program_encounter_type_id);


--
-- Name: group_privilege_program_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgroup_privilege_program_id_index ON group_privilege USING btree (program_id);


--
-- Name: group_privilege_subject_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgroup_privilege_subject_type_id_index ON group_privilege USING btree (subject_type_id);


--
-- Name: group_role_group_subject_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgroup_role_group_subject_type_id_index ON group_role USING btree (group_subject_type_id);


--
-- Name: group_role_member_subject_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgroup_role_member_subject_type_id_index ON group_role USING btree (member_subject_type_id);


--
-- Name: group_subject_group_role_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgroup_subject_group_role_id_index ON group_subject USING btree (group_role_id);


--
-- Name: group_subject_group_subject_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgroup_subject_group_subject_id_index ON group_subject USING btree (group_subject_id);


--
-- Name: group_subject_member_subject_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXgroup_subject_member_subject_id_index ON group_subject USING btree (member_subject_id);


--
-- Name: identifier_assignment_identifier_source_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXidentifier_assignment_identifier_source_id_index ON identifier_assignment USING btree (identifier_source_id);


--
-- Name: identifier_assignment_individual_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXidentifier_assignment_individual_id_index ON identifier_assignment USING btree (individual_id);


--
-- Name: identifier_assignment_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXidentifier_assignment_organisation_id__index ON identifier_assignment USING btree (organisation_id);


--
-- Name: identifier_assignment_program_enrolment_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXidentifier_assignment_program_enrolment_id_index ON identifier_assignment USING btree (program_enrolment_id);


--
-- Name: identifier_source_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXidentifier_source_organisation_id__index ON identifier_source USING btree (organisation_id);


--
-- Name: identifier_user_assignment_identifier_source_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXidentifier_user_assignment_identifier_source_id_index ON identifier_user_assignment USING btree (identifier_source_id);


--
-- Name: identifier_user_assignment_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXidentifier_user_assignment_organisation_id__index ON identifier_user_assignment USING btree (organisation_id);


--
-- Name: idx_individual_obs; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXidx_individual_obs ON individual USING gin (observations jsonb_path_ops);


--
-- Name: idx_program_encounter_obs; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXidx_program_encounter_obs ON program_encounter USING gin (observations jsonb_path_ops);


--
-- Name: idx_program_enrolment_obs; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXidx_program_enrolment_obs ON program_enrolment USING gin (observations jsonb_path_ops);


--
-- Name: individual_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_organisation_id__index ON individual USING btree (organisation_id);


--
-- Name: individual_relation_gender_mapping_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relation_gender_mapping_organisation_id__index ON individual_relation_gender_mapping USING btree (organisation_id);


--
-- Name: individual_relation_gender_mapping_relation_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relation_gender_mapping_relation_id_index ON individual_relation_gender_mapping USING btree (relation_id);


--
-- Name: individual_relation_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relation_organisation_id__index ON individual_relation USING btree (organisation_id);


--
-- Name: individual_relationship_individual_a_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relationship_individual_a_id_index ON individual_relationship USING btree (individual_a_id);


--
-- Name: individual_relationship_individual_b_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relationship_individual_b_id_index ON individual_relationship USING btree (individual_b_id);


--
-- Name: individual_relationship_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relationship_organisation_id__index ON individual_relationship USING btree (organisation_id);


--
-- Name: individual_relationship_relationship_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relationship_relationship_type_id_index ON individual_relationship USING btree (relationship_type_id);


--
-- Name: individual_relationship_type_individual_a_is_to_b_relation_id_i; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relationship_type_individual_a_is_to_b_relation_id_i ON individual_relationship_type USING btree (individual_a_is_to_b_relation_id);


--
-- Name: individual_relationship_type_individual_b_is_to_a_relation_id_i; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relationship_type_individual_b_is_to_a_relation_id_i ON individual_relationship_type USING btree (individual_b_is_to_a_relation_id);


--
-- Name: individual_relationship_type_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relationship_type_organisation_id__index ON individual_relationship_type USING btree (organisation_id);


--
-- Name: individual_relative_individual_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relative_individual_id_index ON individual_relative USING btree (individual_id);


--
-- Name: individual_relative_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relative_organisation_id__index ON individual_relative USING btree (organisation_id);


--
-- Name: individual_relative_relative_individual_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_relative_relative_individual_id_index ON individual_relative USING btree (relative_individual_id);


--
-- Name: individual_subject_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXindividual_subject_type_id_index ON individual USING btree (subject_type_id);


--
-- Name: location_location_mapping_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXlocation_location_mapping_organisation_id__index ON location_location_mapping USING btree (organisation_id);


--
-- Name: non_applicable_form_element_form_element_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXnon_applicable_form_element_form_element_id_index ON non_applicable_form_element USING btree (form_element_id);


--
-- Name: non_applicable_form_element_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXnon_applicable_form_element_organisation_id__index ON non_applicable_form_element USING btree (organisation_id);


--
-- Name: operational_encounter_type_encounter_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXoperational_encounter_type_encounter_type_id_index ON operational_encounter_type USING btree (encounter_type_id);


--
-- Name: operational_encounter_type_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXoperational_encounter_type_organisation_id__index ON operational_encounter_type USING btree (organisation_id);


--
-- Name: operational_program_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXoperational_program_organisation_id__index ON operational_program USING btree (organisation_id);


--
-- Name: operational_program_program_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXoperational_program_program_id_index ON operational_program USING btree (program_id);


--
-- Name: operational_subject_type_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXoperational_subject_type_organisation_id__index ON operational_subject_type USING btree (organisation_id);


--
-- Name: operational_subject_type_subject_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXoperational_subject_type_subject_type_id_index ON operational_subject_type USING btree (subject_type_id);


--
-- Name: program_encounter_encounter_type_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXprogram_encounter_encounter_type_id_index ON program_encounter USING btree (encounter_type_id);


--
-- Name: program_encounter_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXprogram_encounter_organisation_id__index ON program_encounter USING btree (organisation_id);


--
-- Name: program_encounter_program_enrolment_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXprogram_encounter_program_enrolment_id_index ON program_encounter USING btree (program_enrolment_id);


--
-- Name: program_enrolment_individual_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXprogram_enrolment_individual_id_index ON program_enrolment USING btree (individual_id);


--
-- Name: program_enrolment_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXprogram_enrolment_organisation_id__index ON program_enrolment USING btree (organisation_id);


--
-- Name: program_enrolment_program_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXprogram_enrolment_program_id_index ON program_enrolment USING btree (program_id);


--
-- Name: program_organisation_config_at_risk_concept_concept_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXprogram_organisation_config_at_risk_concept_concept_id_index ON program_organisation_config_at_risk_concept USING btree (concept_id);


--
-- Name: program_organisation_config_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXprogram_organisation_config_organisation_id__index ON program_organisation_config USING btree (organisation_id);


--
-- Name: program_organisation_config_program_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXprogram_organisation_config_program_id_index ON program_organisation_config USING btree (program_id);


--
-- Name: program_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXprogram_organisation_id__index ON program USING btree (organisation_id);


--
-- Name: program_outcome_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXprogram_outcome_organisation_id__index ON program_outcome USING btree (organisation_id);


--
-- Name: rule_dependency_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXrule_dependency_organisation_id__index ON rule_dependency USING btree (organisation_id);


--
-- Name: rule_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXrule_organisation_id__index ON rule USING btree (organisation_id);


--
-- Name: schema_version_s_idx; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXschema_version_s_idx ON schema_version USING btree (success);


--
-- Name: subject_type_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXsubject_type_organisation_id__index ON subject_type USING btree (organisation_id);


--
-- Name: sync_telemetry_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXsync_telemetry_organisation_id__index ON sync_telemetry USING btree (organisation_id);


--
-- Name: user_facility_mapping_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXuser_facility_mapping_organisation_id__index ON user_facility_mapping USING btree (organisation_id);


--
-- Name: user_group_group_id_index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXuser_group_group_id_index ON user_group USING btree (group_id);


--
-- Name: users_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXusers_organisation_id__index ON users USING btree (organisation_id);


--
-- Name: users_username_idx; Type: INDEX; Schema: public; Owner: openchs
--

CREATE UNIQUE INDEX users_username_idx ON users USING btree (username);


--
-- Name: video_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXvideo_organisation_id__index ON video USING btree (organisation_id);


--
-- Name: video_telemetric_organisation_id__index; Type: INDEX; Schema: public; Owner: openchs
--

-- CREATE INDEXvideo_telemetric_organisation_id__index ON video_telemetric USING btree (organisation_id);


--
-- Name: account_admin account_admin_account; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY account_admin
    -- ADD CONSTRAINTaccount_admin_account FOREIGN KEY (account_id) REFERENCES account(id);


--
-- Name: account_admin account_admin_user; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY account_admin
    -- ADD CONSTRAINTaccount_admin_user FOREIGN KEY (admin_id) REFERENCES users(id);


--
-- Name: address_level address_level_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level
    -- ADD CONSTRAINTaddress_level_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: address_level address_level_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level
    -- ADD CONSTRAINTaddress_level_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: address_level address_level_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level
    -- ADD CONSTRAINTaddress_level_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES address_level(id);


--
-- Name: address_level address_level_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level
    -- ADD CONSTRAINTaddress_level_type_id_fkey FOREIGN KEY (type_id) REFERENCES address_level_type(id);


--
-- Name: address_level_type address_level_type_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY address_level_type
    -- ADD CONSTRAINTaddress_level_type_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES address_level_type(id);


--
-- Name: catchment_address_mapping catchment_address_mapping_address; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY catchment_address_mapping
    -- ADD CONSTRAINTcatchment_address_mapping_address FOREIGN KEY (addresslevel_id) REFERENCES address_level(id);


--
-- Name: catchment_address_mapping catchment_address_mapping_catchment; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY catchment_address_mapping
    -- ADD CONSTRAINTcatchment_address_mapping_catchment FOREIGN KEY (catchment_id) REFERENCES catchment(id);


--
-- Name: catchment catchment_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY catchment
    -- ADD CONSTRAINTcatchment_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: catchment catchment_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY catchment
    -- ADD CONSTRAINTcatchment_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: checklist checklist_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist
    -- ADD CONSTRAINTchecklist_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: checklist checklist_checklist_detail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist
    -- ADD CONSTRAINTchecklist_checklist_detail_id_fkey FOREIGN KEY (checklist_detail_id) REFERENCES checklist_detail(id);


--
-- Name: checklist_detail checklist_detail_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_detail
    -- ADD CONSTRAINTchecklist_detail_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: checklist_item checklist_item_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item
    -- ADD CONSTRAINTchecklist_item_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: checklist_item checklist_item_checklist; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item
    -- ADD CONSTRAINTchecklist_item_checklist FOREIGN KEY (checklist_id) REFERENCES checklist(id);


--
-- Name: checklist_item checklist_item_checklist_item_detail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item
    -- ADD CONSTRAINTchecklist_item_checklist_item_detail_id_fkey FOREIGN KEY (checklist_item_detail_id) REFERENCES checklist_item_detail(id);


--
-- Name: checklist_item_detail checklist_item_detail_audit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item_detail
    -- ADD CONSTRAINTchecklist_item_detail_audit_id_fkey FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: checklist_item_detail checklist_item_detail_checklist_detail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item_detail
    -- ADD CONSTRAINTchecklist_item_detail_checklist_detail_id_fkey FOREIGN KEY (checklist_detail_id) REFERENCES checklist_detail(id);


--
-- Name: checklist_item_detail checklist_item_detail_concept_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item_detail
    -- ADD CONSTRAINTchecklist_item_detail_concept_id_fkey FOREIGN KEY (concept_id) REFERENCES concept(id);


--
-- Name: checklist_item_detail checklist_item_detail_dependent_on_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item_detail
    -- ADD CONSTRAINTchecklist_item_detail_dependent_on_fkey FOREIGN KEY (dependent_on) REFERENCES checklist_item_detail(id);


--
-- Name: checklist_item_detail checklist_item_detail_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item_detail
    -- ADD CONSTRAINTchecklist_item_detail_form_id_fkey FOREIGN KEY (form_id) REFERENCES form(id);


--
-- Name: checklist_item_detail checklist_item_detail_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item_detail
    -- ADD CONSTRAINTchecklist_item_detail_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: checklist_item checklist_item_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist_item
    -- ADD CONSTRAINTchecklist_item_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: checklist checklist_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist
    -- ADD CONSTRAINTchecklist_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: checklist checklist_program_enrolment; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY checklist
    -- ADD CONSTRAINTchecklist_program_enrolment FOREIGN KEY (program_enrolment_id) REFERENCES program_enrolment(id);


--
-- Name: concept_answer concept_answer_answer_concept; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept_answer
    -- ADD CONSTRAINTconcept_answer_answer_concept FOREIGN KEY (answer_concept_id) REFERENCES concept(id);


--
-- Name: concept_answer concept_answer_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept_answer
    -- ADD CONSTRAINTconcept_answer_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: concept_answer concept_answer_concept; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept_answer
    -- ADD CONSTRAINTconcept_answer_concept FOREIGN KEY (concept_id) REFERENCES concept(id);


--
-- Name: concept_answer concept_answer_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept_answer
    -- ADD CONSTRAINTconcept_answer_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: concept concept_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept
    -- ADD CONSTRAINTconcept_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: concept concept_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY concept
    -- ADD CONSTRAINTconcept_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: encounter encounter_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter
    -- ADD CONSTRAINTencounter_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: encounter encounter_encounter_type; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter
    -- ADD CONSTRAINTencounter_encounter_type FOREIGN KEY (encounter_type_id) REFERENCES encounter_type(id);


--
-- Name: encounter encounter_individual; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter
    -- ADD CONSTRAINTencounter_individual FOREIGN KEY (individual_id) REFERENCES individual(id);


--
-- Name: encounter encounter_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter
    -- ADD CONSTRAINTencounter_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: encounter_type encounter_type_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter_type
    -- ADD CONSTRAINTencounter_type_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: encounter_type encounter_type_concept; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter_type
    -- ADD CONSTRAINTencounter_type_concept FOREIGN KEY (concept_id) REFERENCES concept(id);


--
-- Name: encounter_type encounter_type_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY encounter_type
    -- ADD CONSTRAINTencounter_type_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: facility facility_address; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY facility
    -- ADD CONSTRAINTfacility_address FOREIGN KEY (address_id) REFERENCES address_level(id);


--
-- Name: form form_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form
    -- ADD CONSTRAINTform_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: form_element form_element_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element
    -- ADD CONSTRAINTform_element_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: form_element form_element_concept; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element
    -- ADD CONSTRAINTform_element_concept FOREIGN KEY (concept_id) REFERENCES concept(id);


--
-- Name: form_element form_element_form_element_group; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element
    -- ADD CONSTRAINTform_element_form_element_group FOREIGN KEY (form_element_group_id) REFERENCES form_element_group(id);


--
-- Name: form_element_group form_element_group_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element_group
    -- ADD CONSTRAINTform_element_group_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: form_element_group form_element_group_form; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element_group
    -- ADD CONSTRAINTform_element_group_form FOREIGN KEY (form_id) REFERENCES form(id);


--
-- Name: form_element_group form_element_group_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element_group
    -- ADD CONSTRAINTform_element_group_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: form_element form_element_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_element
    -- ADD CONSTRAINTform_element_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: form_mapping form_mapping_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_mapping
    -- ADD CONSTRAINTform_mapping_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: form_mapping form_mapping_form; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_mapping
    -- ADD CONSTRAINTform_mapping_form FOREIGN KEY (form_id) REFERENCES form(id);


--
-- Name: form_mapping form_mapping_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_mapping
    -- ADD CONSTRAINTform_mapping_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: form_mapping form_mapping_subject_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form_mapping
    -- ADD CONSTRAINTform_mapping_subject_type_id_fkey FOREIGN KEY (subject_type_id) REFERENCES subject_type(id);


--
-- Name: form form_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY form
    -- ADD CONSTRAINTform_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: gender gender_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY gender
    -- ADD CONSTRAINTgender_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: gender gender_concept; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY gender
    -- ADD CONSTRAINTgender_concept FOREIGN KEY (concept_id) REFERENCES concept(id);


--
-- Name: gender gender_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY gender
    -- ADD CONSTRAINTgender_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: groups group_master_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY groups
    -- ADD CONSTRAINTgroup_master_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: groups group_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY groups
    -- ADD CONSTRAINTgroup_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: group_privilege group_privilege_checklist_detail_id; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_privilege
    -- ADD CONSTRAINTgroup_privilege_checklist_detail_id FOREIGN KEY (checklist_detail_id) REFERENCES checklist_detail(id);


--
-- Name: group_privilege group_privilege_encounter_type_id; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_privilege
    -- ADD CONSTRAINTgroup_privilege_encounter_type_id FOREIGN KEY (encounter_type_id) REFERENCES encounter_type(id);


--
-- Name: group_privilege group_privilege_group_id; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_privilege
    -- ADD CONSTRAINTgroup_privilege_group_id FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: group_privilege group_privilege_master_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_privilege
    -- ADD CONSTRAINTgroup_privilege_master_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: group_privilege group_privilege_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_privilege
    -- ADD CONSTRAINTgroup_privilege_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: group_privilege group_privilege_program_encounter_type_id; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_privilege
    -- ADD CONSTRAINTgroup_privilege_program_encounter_type_id FOREIGN KEY (program_encounter_type_id) REFERENCES encounter_type(id);


--
-- Name: group_privilege group_privilege_program_id; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_privilege
    -- ADD CONSTRAINTgroup_privilege_program_id FOREIGN KEY (program_id) REFERENCES program(id);


--
-- Name: group_privilege group_privilege_subject_id; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_privilege
    -- ADD CONSTRAINTgroup_privilege_subject_id FOREIGN KEY (subject_type_id) REFERENCES subject_type(id);


--
-- Name: group_role group_role_group_subject_type; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_role
    -- ADD CONSTRAINTgroup_role_group_subject_type FOREIGN KEY (group_subject_type_id) REFERENCES subject_type(id);


--
-- Name: group_role group_role_master_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_role
    -- ADD CONSTRAINTgroup_role_master_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: group_role group_role_member_subject_type; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_role
    -- ADD CONSTRAINTgroup_role_member_subject_type FOREIGN KEY (member_subject_type_id) REFERENCES subject_type(id);


--
-- Name: group_role group_role_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_role
    -- ADD CONSTRAINTgroup_role_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: group_subject group_subject_group_role; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_subject
    -- ADD CONSTRAINTgroup_subject_group_role FOREIGN KEY (group_role_id) REFERENCES group_role(id);


--
-- Name: group_subject group_subject_group_subject; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_subject
    -- ADD CONSTRAINTgroup_subject_group_subject FOREIGN KEY (group_subject_id) REFERENCES individual(id);


--
-- Name: group_subject group_subject_master_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_subject
    -- ADD CONSTRAINTgroup_subject_master_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: group_subject group_subject_member_subject; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_subject
    -- ADD CONSTRAINTgroup_subject_member_subject FOREIGN KEY (member_subject_id) REFERENCES individual(id);


--
-- Name: group_subject group_subject_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY group_subject
    -- ADD CONSTRAINTgroup_subject_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: identifier_assignment identifier_assignment_assigned_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_assignment
    -- ADD CONSTRAINTidentifier_assignment_assigned_to_user_id_fkey FOREIGN KEY (assigned_to_user_id) REFERENCES users(id);


--
-- Name: identifier_assignment identifier_assignment_audit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_assignment
    -- ADD CONSTRAINTidentifier_assignment_audit_id_fkey FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: identifier_assignment identifier_assignment_identifier_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_assignment
    -- ADD CONSTRAINTidentifier_assignment_identifier_source_id_fkey FOREIGN KEY (identifier_source_id) REFERENCES identifier_source(id);


--
-- Name: identifier_assignment identifier_assignment_individual_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_assignment
    -- ADD CONSTRAINTidentifier_assignment_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES individual(id);


--
-- Name: identifier_assignment identifier_assignment_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_assignment
    -- ADD CONSTRAINTidentifier_assignment_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: identifier_assignment identifier_assignment_program_enrolment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_assignment
    -- ADD CONSTRAINTidentifier_assignment_program_enrolment_id_fkey FOREIGN KEY (program_enrolment_id) REFERENCES program_enrolment(id);


--
-- Name: identifier_source identifier_source_audit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_source
    -- ADD CONSTRAINTidentifier_source_audit_id_fkey FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: identifier_source identifier_source_catchment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_source
    -- ADD CONSTRAINTidentifier_source_catchment_id_fkey FOREIGN KEY (catchment_id) REFERENCES catchment(id);


--
-- Name: identifier_source identifier_source_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_source
    -- ADD CONSTRAINTidentifier_source_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES facility(id);


--
-- Name: identifier_source identifier_source_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_source
    -- ADD CONSTRAINTidentifier_source_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: identifier_user_assignment identifier_user_assignment_assigned_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_user_assignment
    -- ADD CONSTRAINTidentifier_user_assignment_assigned_to_user_id_fkey FOREIGN KEY (assigned_to_user_id) REFERENCES users(id);


--
-- Name: identifier_user_assignment identifier_user_assignment_audit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_user_assignment
    -- ADD CONSTRAINTidentifier_user_assignment_audit_id_fkey FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: identifier_user_assignment identifier_user_assignment_identifier_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_user_assignment
    -- ADD CONSTRAINTidentifier_user_assignment_identifier_source_id_fkey FOREIGN KEY (identifier_source_id) REFERENCES identifier_source(id);


--
-- Name: identifier_user_assignment identifier_user_assignment_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY identifier_user_assignment
    -- ADD CONSTRAINTidentifier_user_assignment_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: individual individual_address; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual
    -- ADD CONSTRAINTindividual_address FOREIGN KEY (address_id) REFERENCES address_level(id);


--
-- Name: individual individual_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual
    -- ADD CONSTRAINTindividual_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: individual individual_facility; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual
    -- ADD CONSTRAINTindividual_facility FOREIGN KEY (facility_id) REFERENCES facility(id);


--
-- Name: individual individual_gender; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual
    -- ADD CONSTRAINTindividual_gender FOREIGN KEY (gender_id) REFERENCES gender(id);


--
-- Name: individual individual_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual
    -- ADD CONSTRAINTindividual_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: individual_relative individual_relation_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relative
    -- ADD CONSTRAINTindividual_relation_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: individual_relation individual_relation_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relation
    -- ADD CONSTRAINTindividual_relation_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: individual_relation_gender_mapping individual_relation_gender_mapping_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relation_gender_mapping
    -- ADD CONSTRAINTindividual_relation_gender_mapping_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: individual_relation_gender_mapping individual_relation_gender_mapping_gender; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relation_gender_mapping
    -- ADD CONSTRAINTindividual_relation_gender_mapping_gender FOREIGN KEY (gender_id) REFERENCES gender(id);


--
-- Name: individual_relation_gender_mapping individual_relation_gender_mapping_relation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relation_gender_mapping
    -- ADD CONSTRAINTindividual_relation_gender_mapping_relation FOREIGN KEY (relation_id) REFERENCES individual_relation(id);


--
-- Name: individual_relationship individual_relationship_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relationship
    -- ADD CONSTRAINTindividual_relationship_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: individual_relationship individual_relationship_individual_a; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relationship
    -- ADD CONSTRAINTindividual_relationship_individual_a FOREIGN KEY (individual_a_id) REFERENCES individual(id);


--
-- Name: individual_relationship individual_relationship_individual_b; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relationship
    -- ADD CONSTRAINTindividual_relationship_individual_b FOREIGN KEY (individual_b_id) REFERENCES individual(id);


--
-- Name: individual_relationship individual_relationship_relation_type; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relationship
    -- ADD CONSTRAINTindividual_relationship_relation_type FOREIGN KEY (relationship_type_id) REFERENCES individual_relationship_type(id);


--
-- Name: individual_relationship_type individual_relationship_type_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relationship_type
    -- ADD CONSTRAINTindividual_relationship_type_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: individual_relationship_type individual_relationship_type_individual_a_relation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relationship_type
    -- ADD CONSTRAINTindividual_relationship_type_individual_a_relation FOREIGN KEY (individual_a_is_to_b_relation_id) REFERENCES individual_relation(id);


--
-- Name: individual_relationship_type individual_relationship_type_individual_b_relation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relationship_type
    -- ADD CONSTRAINTindividual_relationship_type_individual_b_relation FOREIGN KEY (individual_b_is_to_a_relation_id) REFERENCES individual_relation(id);


--
-- Name: individual_relative individual_relative_individual; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relative
    -- ADD CONSTRAINTindividual_relative_individual FOREIGN KEY (individual_id) REFERENCES individual(id);


--
-- Name: individual_relative individual_relative_relative_individual; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual_relative
    -- ADD CONSTRAINTindividual_relative_relative_individual FOREIGN KEY (relative_individual_id) REFERENCES individual(id);


--
-- Name: individual individual_subject_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY individual
    -- ADD CONSTRAINTindividual_subject_type_id_fkey FOREIGN KEY (subject_type_id) REFERENCES subject_type(id);


--
-- Name: batch_job_execution_context job_exec_ctx_fk; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY batch_job_execution_context
    -- ADD CONSTRAINTjob_exec_ctx_fk FOREIGN KEY (job_execution_id) REFERENCES batch_job_execution(job_execution_id);


--
-- Name: batch_job_execution_params job_exec_params_fk; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY batch_job_execution_params
    -- ADD CONSTRAINTjob_exec_params_fk FOREIGN KEY (job_execution_id) REFERENCES batch_job_execution(job_execution_id);


--
-- Name: batch_step_execution job_exec_step_fk; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY batch_step_execution
    -- ADD CONSTRAINTjob_exec_step_fk FOREIGN KEY (job_execution_id) REFERENCES batch_job_execution(job_execution_id);


--
-- Name: batch_job_execution job_inst_exec_fk; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY batch_job_execution
    -- ADD CONSTRAINTjob_inst_exec_fk FOREIGN KEY (job_instance_id) REFERENCES batch_job_instance(job_instance_id);


--
-- Name: location_location_mapping location_location_mapping_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY location_location_mapping
    -- ADD CONSTRAINTlocation_location_mapping_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: location_location_mapping location_location_mapping_location; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY location_location_mapping
    -- ADD CONSTRAINTlocation_location_mapping_location FOREIGN KEY (location_id) REFERENCES address_level(id);


--
-- Name: location_location_mapping location_location_mapping_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY location_location_mapping
    -- ADD CONSTRAINTlocation_location_mapping_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: location_location_mapping location_location_mapping_parent_location; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY location_location_mapping
    -- ADD CONSTRAINTlocation_location_mapping_parent_location FOREIGN KEY (parent_location_id) REFERENCES address_level(id);


--
-- Name: non_applicable_form_element non_applicable_form_element_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY non_applicable_form_element
    -- ADD CONSTRAINTnon_applicable_form_element_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: non_applicable_form_element non_applicable_form_element_form_element_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY non_applicable_form_element
    -- ADD CONSTRAINTnon_applicable_form_element_form_element_id_fkey FOREIGN KEY (form_element_id) REFERENCES form_element(id);


--
-- Name: non_applicable_form_element non_applicable_form_element_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY non_applicable_form_element
    -- ADD CONSTRAINTnon_applicable_form_element_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: operational_encounter_type operational_encounter_type_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_encounter_type
    -- ADD CONSTRAINToperational_encounter_type_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: operational_encounter_type operational_encounter_type_encounter_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_encounter_type
    -- ADD CONSTRAINToperational_encounter_type_encounter_type_id_fkey FOREIGN KEY (encounter_type_id) REFERENCES encounter_type(id);


--
-- Name: operational_encounter_type operational_encounter_type_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_encounter_type
    -- ADD CONSTRAINToperational_encounter_type_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: operational_program operational_program_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_program
    -- ADD CONSTRAINToperational_program_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: operational_program operational_program_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_program
    -- ADD CONSTRAINToperational_program_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: operational_program operational_program_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_program
    -- ADD CONSTRAINToperational_program_program_id_fkey FOREIGN KEY (program_id) REFERENCES program(id);


--
-- Name: operational_subject_type operational_subject_type_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_subject_type
    -- ADD CONSTRAINToperational_subject_type_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: operational_subject_type operational_subject_type_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_subject_type
    -- ADD CONSTRAINToperational_subject_type_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: operational_subject_type operational_subject_type_subject_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY operational_subject_type
    -- ADD CONSTRAINToperational_subject_type_subject_type_id_fkey FOREIGN KEY (subject_type_id) REFERENCES subject_type(id);


--
-- Name: organisation organisation_account; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation
    -- ADD CONSTRAINTorganisation_account FOREIGN KEY (account_id) REFERENCES account(id);


--
-- Name: organisation_config organisation_config_master_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_config
    -- ADD CONSTRAINTorganisation_config_master_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: organisation_config organisation_config_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_config
    -- ADD CONSTRAINTorganisation_config_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: organisation_group organisation_group_account; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_group
    -- ADD CONSTRAINTorganisation_group_account FOREIGN KEY (account_id) REFERENCES account(id);


--
-- Name: organisation_group_organisation organisation_group_organisation_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_group_organisation
    -- ADD CONSTRAINTorganisation_group_organisation_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: organisation_group_organisation organisation_group_organisation_organisation_group; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation_group_organisation
    -- ADD CONSTRAINTorganisation_group_organisation_organisation_group FOREIGN KEY (organisation_group_id) REFERENCES organisation_group(id);


--
-- Name: organisation organisation_parent_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY organisation
    -- ADD CONSTRAINTorganisation_parent_organisation_id_fkey FOREIGN KEY (parent_organisation_id) REFERENCES organisation(id);


--
-- Name: program program_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program
    -- ADD CONSTRAINTprogram_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: program_encounter program_encounter_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_encounter
    -- ADD CONSTRAINTprogram_encounter_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: program_encounter program_encounter_encounter_type; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_encounter
    -- ADD CONSTRAINTprogram_encounter_encounter_type FOREIGN KEY (encounter_type_id) REFERENCES encounter_type(id);


--
-- Name: program_encounter program_encounter_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_encounter
    -- ADD CONSTRAINTprogram_encounter_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: program_encounter program_encounter_program_enrolment; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_encounter
    -- ADD CONSTRAINTprogram_encounter_program_enrolment FOREIGN KEY (program_enrolment_id) REFERENCES program_enrolment(id);


--
-- Name: program_enrolment program_enrolment_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_enrolment
    -- ADD CONSTRAINTprogram_enrolment_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: program_enrolment program_enrolment_individual; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_enrolment
    -- ADD CONSTRAINTprogram_enrolment_individual FOREIGN KEY (individual_id) REFERENCES individual(id);


--
-- Name: program_enrolment program_enrolment_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_enrolment
    -- ADD CONSTRAINTprogram_enrolment_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: program_enrolment program_enrolment_program; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_enrolment
    -- ADD CONSTRAINTprogram_enrolment_program FOREIGN KEY (program_id) REFERENCES program(id);


--
-- Name: program_enrolment program_enrolment_program_outcome; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_enrolment
    -- ADD CONSTRAINTprogram_enrolment_program_outcome FOREIGN KEY (program_outcome_id) REFERENCES program_outcome(id);


--
-- Name: program_organisation_config_at_risk_concept program_organisation_config_a_program_organisation_config__fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_organisation_config_at_risk_concept
    -- ADD CONSTRAINTprogram_organisation_config_a_program_organisation_config__fkey FOREIGN KEY (program_organisation_config_id) REFERENCES program_organisation_config(id);


--
-- Name: program_organisation_config_at_risk_concept program_organisation_config_at_risk_concept_concept_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_organisation_config_at_risk_concept
    -- ADD CONSTRAINTprogram_organisation_config_at_risk_concept_concept_id_fkey FOREIGN KEY (concept_id) REFERENCES concept(id);


--
-- Name: program_organisation_config program_organisation_config_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_organisation_config
    -- ADD CONSTRAINTprogram_organisation_config_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: program_organisation_config program_organisation_config_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_organisation_config
    -- ADD CONSTRAINTprogram_organisation_config_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: program_organisation_config program_organisation_config_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_organisation_config
    -- ADD CONSTRAINTprogram_organisation_config_program_id_fkey FOREIGN KEY (program_id) REFERENCES program(id);


--
-- Name: program program_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program
    -- ADD CONSTRAINTprogram_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: program_outcome program_outcome_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_outcome
    -- ADD CONSTRAINTprogram_outcome_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: program_outcome program_outcome_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY program_outcome
    -- ADD CONSTRAINTprogram_outcome_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: rule rule_audit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule
    -- ADD CONSTRAINTrule_audit_id_fkey FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: rule_dependency rule_dependency_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule_dependency
    -- ADD CONSTRAINTrule_dependency_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: rule_failure_telemetry rule_failure_telemetry_master_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule_failure_telemetry
    -- ADD CONSTRAINTrule_failure_telemetry_master_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: rule_failure_telemetry rule_failure_telemetry_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule_failure_telemetry
    -- ADD CONSTRAINTrule_failure_telemetry_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: rule_failure_telemetry rule_failure_telemetry_user; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule_failure_telemetry
    -- ADD CONSTRAINTrule_failure_telemetry_user FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: rule rule_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule
    -- ADD CONSTRAINTrule_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: rule rule_rule_dependency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY rule
    -- ADD CONSTRAINTrule_rule_dependency_id_fkey FOREIGN KEY (rule_dependency_id) REFERENCES rule_dependency(id);


--
-- Name: batch_step_execution_context step_exec_ctx_fk; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY batch_step_execution_context
    -- ADD CONSTRAINTstep_exec_ctx_fk FOREIGN KEY (step_execution_id) REFERENCES batch_step_execution(step_execution_id);


--
-- Name: subject_type subject_type_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY subject_type
    -- ADD CONSTRAINTsubject_type_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: subject_type subject_type_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY subject_type
    -- ADD CONSTRAINTsubject_type_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: sync_telemetry sync_telemetry_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY sync_telemetry
    -- ADD CONSTRAINTsync_telemetry_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: sync_telemetry sync_telemetry_user; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY sync_telemetry
    -- ADD CONSTRAINTsync_telemetry_user FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: translation translation_master_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY translation
    -- ADD CONSTRAINTtranslation_master_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: translation translation_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY translation
    -- ADD CONSTRAINTtranslation_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: user_facility_mapping user_facility_mapping_facility; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY user_facility_mapping
    -- ADD CONSTRAINTuser_facility_mapping_facility FOREIGN KEY (facility_id) REFERENCES facility(id);


--
-- Name: user_facility_mapping user_facility_mapping_user; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY user_facility_mapping
    -- ADD CONSTRAINTuser_facility_mapping_user FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_group user_group_group_id; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY user_group
    -- ADD CONSTRAINTuser_group_group_id FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: user_group user_group_master_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY user_group
    -- ADD CONSTRAINTuser_group_master_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: user_group user_group_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY user_group
    -- ADD CONSTRAINTuser_group_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: user_group user_group_user_id; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY user_group
    -- ADD CONSTRAINTuser_group_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: users users_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY users
    -- ADD CONSTRAINTusers_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: video video_audit; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY video
    -- ADD CONSTRAINTvideo_audit FOREIGN KEY (audit_id) REFERENCES audit(id);


--
-- Name: video video_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY video
    -- ADD CONSTRAINTvideo_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: video_telemetric video_telemetric_organisation; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY video_telemetric
    -- ADD CONSTRAINTvideo_telemetric_organisation FOREIGN KEY (organisation_id) REFERENCES organisation(id);


--
-- Name: video_telemetric video_telemetric_user; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY video_telemetric
    -- ADD CONSTRAINTvideo_telemetric_user FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: video_telemetric video_telemetric_video; Type: FK CONSTRAINT; Schema: public; Owner: openchs
--

-- ALTER TABLEONLY video_telemetric
    -- ADD CONSTRAINTvideo_telemetric_video FOREIGN KEY (video_id) REFERENCES video(id);


--
-- Name: address_level; Type: ROW SECURITY; Schema: public; Owner: openchs
--

-- ALTER TABLEaddress_level ENABLE ROW LEVEL SECURITY;

--
-- Name: address_level address_level_orgs; Type: POLICY; Schema: public; Owner: openchs
--


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

