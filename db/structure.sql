SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: _old_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._old_users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_name character varying NOT NULL,
    first_name character varying NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: _old_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public._old_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: _old_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public._old_users_id_seq OWNED BY public._old_users.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id bigint NOT NULL,
    starts_on timestamp without time zone,
    ends_on timestamp without time zone,
    user_id bigint,
    amount_paid_cents integer DEFAULT 0 NOT NULL,
    amount_paid_currency character varying DEFAULT 'USD'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    membership_type_id bigint NOT NULL
);


--
-- Name: current_memberships; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.current_memberships AS
 SELECT m.id,
    m.starts_on,
    m.ends_on,
    m.user_id,
    m.amount_paid_cents,
    m.amount_paid_currency,
    m.seqnum
   FROM ( SELECT m_1.id,
            m_1.starts_on,
            m_1.ends_on,
            m_1.user_id,
            m_1.amount_paid_cents,
            m_1.amount_paid_currency,
            row_number() OVER (PARTITION BY m_1.user_id ORDER BY m_1.ends_on DESC) AS seqnum
           FROM public.memberships m_1
          WHERE (m_1.starts_on <= ('now'::text)::date)) m
  WHERE (m.seqnum = 1);


--
-- Name: membership_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_types (
    id bigint NOT NULL,
    name character varying NOT NULL,
    "position" integer NOT NULL,
    description character varying NOT NULL,
    price_cents integer DEFAULT 0 NOT NULL,
    price_currency character varying DEFAULT 'USD'::character varying NOT NULL,
    discarded_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approval_required boolean DEFAULT false NOT NULL
);


--
-- Name: membership_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.membership_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: membership_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.membership_types_id_seq OWNED BY public.membership_types.id;


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.memberships_id_seq OWNED BY public.memberships.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying NOT NULL,
    permissions text[] DEFAULT '{}'::text[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: roles_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles_users (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying NOT NULL,
    last_name character varying NOT NULL,
    first_name character varying NOT NULL,
    password_digest character varying NOT NULL,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    unconfirmed_email character varying,
    discarded_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._old_users ALTER COLUMN id SET DEFAULT nextval('public._old_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_types ALTER COLUMN id SET DEFAULT nextval('public.membership_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: _old_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._old_users
    ADD CONSTRAINT _old_users_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: membership_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_types
    ADD CONSTRAINT membership_types_pkey PRIMARY KEY (id);


--
-- Name: memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: _old_users_email_uniq_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX _old_users_email_uniq_idx ON public._old_users USING btree (email);


--
-- Name: index__old_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index__old_users_on_confirmation_token ON public._old_users USING btree (confirmation_token);


--
-- Name: index__old_users_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index__old_users_on_discarded_at ON public._old_users USING btree (discarded_at);


--
-- Name: index__old_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index__old_users_on_email ON public._old_users USING btree (email);


--
-- Name: index__old_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index__old_users_on_reset_password_token ON public._old_users USING btree (reset_password_token);


--
-- Name: index__old_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index__old_users_on_unlock_token ON public._old_users USING btree (unlock_token);


--
-- Name: index_membership_types_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_types_on_discarded_at ON public.membership_types USING btree (discarded_at);


--
-- Name: index_membership_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_membership_types_on_name ON public.membership_types USING btree (name);


--
-- Name: index_membership_types_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_types_on_position ON public.membership_types USING btree ("position");


--
-- Name: index_memberships_on_membership_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_membership_type_id ON public.memberships USING btree (membership_type_id);


--
-- Name: index_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_user_id ON public.memberships USING btree (user_id);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_name ON public.roles USING btree (name);


--
-- Name: index_roles_users_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_users_on_user_id_and_role_id ON public.roles_users USING btree (user_id, role_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_first_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_first_name ON public.users USING btree (first_name);


--
-- Name: index_users_on_last_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_last_name ON public.users USING btree (last_name);


--
-- Name: fk_rails_99326fb65d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_99326fb65d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20180209211146'),
('20180213065655'),
('20180215233812'),
('20180216000821'),
('20180216001502'),
('20180218000518'),
('20180218001434'),
('20180218010534'),
('20180218194755'),
('20180219174544'),
('20180223005942'),
('20180223055132'),
('20180223062441'),
('20180225060122'),
('20180409165901');


