--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3 (Ubuntu 15.3-1.pgdg20.04+1)
-- Dumped by pg_dump version 15.3 (Ubuntu 15.3-1.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: location_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.location_type AS ENUM (
    'Warehouse',
    'Factory',
    'Repair',
    'Supplier',
    'Customer'
);


ALTER TYPE public.location_type OWNER TO postgres;

--
-- Name: mo_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.mo_status AS ENUM (
    'Draft',
    'Pending',
    'Reserved',
    'In Progress',
    'Completed',
    'Cancelled'
);


ALTER TYPE public.mo_status OWNER TO postgres;

--
-- Name: mo_status_temp; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.mo_status_temp AS ENUM (
    'Draft',
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled'
);


ALTER TYPE public.mo_status_temp OWNER TO postgres;

--
-- Name: po_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.po_status AS ENUM (
    'Draft',
    'Pending Approval',
    'Approved',
    'In Progress',
    'Completed',
    'Cancelled'
);


ALTER TYPE public.po_status OWNER TO postgres;

--
-- Name: update_received_date(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_received_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.status = 'Completed' THEN
    NEW.received_date := NOW();
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_received_date() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bom; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bom (
    id integer NOT NULL,
    product_id integer
);


ALTER TABLE public.bom OWNER TO postgres;

--
-- Name: bom_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bom_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bom_id_seq OWNER TO postgres;

--
-- Name: bom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bom_id_seq OWNED BY public.bom.id;


--
-- Name: bom_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bom_line (
    id integer NOT NULL,
    bom_id integer,
    component_id integer,
    quantity integer
);


ALTER TABLE public.bom_line OWNER TO postgres;

--
-- Name: bom_line_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bom_line_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bom_line_id_seq OWNER TO postgres;

--
-- Name: bom_line_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bom_line_id_seq OWNED BY public.bom_line.id;


--
-- Name: inventory_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_item (
    id integer NOT NULL,
    product_id integer,
    serial_number uuid DEFAULT public.uuid_generate_v4(),
    location public.location_type,
    po_line_id integer,
    mo_id integer
);


ALTER TABLE public.inventory_item OWNER TO postgres;

--
-- Name: inventory_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_item_id_seq OWNER TO postgres;

--
-- Name: inventory_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventory_item_id_seq OWNED BY public.inventory_item.id;


--
-- Name: mo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mo (
    id integer NOT NULL,
    date_created timestamp with time zone DEFAULT now(),
    date_done timestamp with time zone,
    bom_id integer,
    status public.mo_status DEFAULT 'Draft'::public.mo_status,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['Draft'::public.mo_status, 'Pending'::public.mo_status, 'Reserved'::public.mo_status, 'In Progress'::public.mo_status, 'Completed'::public.mo_status, 'Cancelled'::public.mo_status])))
);


ALTER TABLE public.mo OWNER TO postgres;

--
-- Name: mo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mo_id_seq OWNER TO postgres;

--
-- Name: mo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mo_id_seq OWNED BY public.mo.id;


--
-- Name: po; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.po (
    id integer NOT NULL,
    date_created timestamp with time zone DEFAULT now(),
    status public.po_status DEFAULT 'Draft'::public.po_status,
    supplier_id integer,
    received_date timestamp without time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['Draft'::public.po_status, 'Pending Approval'::public.po_status, 'Approved'::public.po_status, 'In Progress'::public.po_status, 'Completed'::public.po_status, 'Cancelled'::public.po_status])))
);


ALTER TABLE public.po OWNER TO postgres;

--
-- Name: po_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.po_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.po_id_seq OWNER TO postgres;

--
-- Name: po_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.po_id_seq OWNED BY public.po.id;


--
-- Name: po_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.po_line (
    id integer NOT NULL,
    po_id integer,
    product_id integer,
    quantity integer
);


ALTER TABLE public.po_line OWNER TO postgres;

--
-- Name: po_line_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.po_line_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.po_line_id_seq OWNER TO postgres;

--
-- Name: po_line_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.po_line_id_seq OWNED BY public.po_line.id;


--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    id integer NOT NULL,
    name character varying(255),
    description text,
    price numeric(10,2),
    is_assembly boolean DEFAULT false
);


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_id_seq OWNER TO postgres;

--
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;


--
-- Name: stock_move; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_move (
    id integer NOT NULL,
    inventory_item_id integer,
    source_location public.location_type,
    destination_location public.location_type,
    move_date timestamp with time zone DEFAULT now()
);


ALTER TABLE public.stock_move OWNER TO postgres;

--
-- Name: stock_move_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stock_move_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stock_move_id_seq OWNER TO postgres;

--
-- Name: stock_move_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stock_move_id_seq OWNED BY public.stock_move.id;


--
-- Name: supplier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier (
    id integer NOT NULL,
    name character varying(255),
    contact character varying(255)
);


ALTER TABLE public.supplier OWNER TO postgres;

--
-- Name: supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.supplier_id_seq OWNER TO postgres;

--
-- Name: supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.supplier_id_seq OWNED BY public.supplier.id;


--
-- Name: bom id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bom ALTER COLUMN id SET DEFAULT nextval('public.bom_id_seq'::regclass);


--
-- Name: bom_line id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bom_line ALTER COLUMN id SET DEFAULT nextval('public.bom_line_id_seq'::regclass);


--
-- Name: inventory_item id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item ALTER COLUMN id SET DEFAULT nextval('public.inventory_item_id_seq'::regclass);


--
-- Name: mo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mo ALTER COLUMN id SET DEFAULT nextval('public.mo_id_seq'::regclass);


--
-- Name: po id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.po ALTER COLUMN id SET DEFAULT nextval('public.po_id_seq'::regclass);


--
-- Name: po_line id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.po_line ALTER COLUMN id SET DEFAULT nextval('public.po_line_id_seq'::regclass);


--
-- Name: product id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);


--
-- Name: stock_move id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_move ALTER COLUMN id SET DEFAULT nextval('public.stock_move_id_seq'::regclass);


--
-- Name: supplier id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier ALTER COLUMN id SET DEFAULT nextval('public.supplier_id_seq'::regclass);


--
-- Data for Name: bom; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bom (id, product_id) FROM stdin;
7	36
8	34
\.


--
-- Data for Name: bom_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bom_line (id, bom_id, component_id, quantity) FROM stdin;
49	7	15	1
50	7	16	1
51	7	17	1
52	7	18	3
53	7	19	1
54	7	20	1
55	7	21	1
56	7	22	2
57	7	23	1
58	7	26	1
59	7	27	1
60	8	1	1
61	8	2	10
62	8	3	1
63	8	4	1
64	8	5	1
65	8	6	4
66	8	7	1
67	8	8	1
68	8	9	2
69	8	10	1
70	8	11	2
71	8	12	4
72	8	13	3
73	8	14	4
\.


--
-- Data for Name: inventory_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_item (id, product_id, serial_number, location, po_line_id, mo_id) FROM stdin;
35	1	76b9d7fb-8d2e-4c99-8139-2802cad5e348	Factory	22	1
8	2	c253b798-afab-4332-9a0e-f9c0ee3d66a5	Factory	10	1
10	2	0183ab78-12dd-4648-81ef-2496ee12d46e	Factory	10	1
9	2	39a5116b-c85a-4858-adb3-31b316faa769	Factory	10	1
7	2	d3e1fa1c-f939-4467-aa27-4da24bde9b23	Factory	10	1
1	2	8bebdab6-bfca-4d08-b0de-28f355f6ffc0	Factory	10	1
5	2	93cbbfaf-1efa-4762-8107-8b886e639853	Factory	10	1
4	2	deb41749-b931-48d8-9102-e64035a6e599	Factory	10	1
2	2	34f16081-87c9-4103-b897-e4a5f7856930	Factory	10	1
6	2	99084911-2f3a-40c7-9511-d55e2031e5be	Factory	10	1
3	2	4b907ba4-ba70-459f-8f8c-6384cc328be3	Factory	10	1
36	3	e886295c-b4b8-430a-b8a6-7ff094041839	Factory	23	1
15	4	df8e8381-e887-4653-8ef7-fe9273ab3abe	Factory	12	1
16	5	73b191a8-fb4a-4d2b-b93a-668e91cf74d6	Factory	13	1
19	6	71ff2209-fff4-4daf-8dd2-58212b0f2650	Factory	14	1
17	6	80d248bc-69d1-4956-87c0-92866a842f48	Factory	14	1
20	6	9b61b42a-0db4-48c2-8dcf-0b1fc6701ff7	Factory	14	1
18	6	7360d84b-8202-4649-94f3-f48866e3f91d	Factory	14	1
21	7	778dd1aa-f126-4f29-8963-083c4587297c	Factory	15	1
22	8	9af58b68-3bf5-4830-b6a1-a2f8b9d75d23	Factory	16	1
24	9	eddd7869-7208-40cb-b757-e59c796e87b3	Factory	17	1
23	9	83efdf38-d753-4ee3-9974-0f994f5dee9c	Factory	17	1
25	10	e3993e83-7a0e-4fe6-b821-2e0ae28a0ebe	Factory	18	1
26	11	8cf7bed4-6e04-42cd-ab04-a5035f7ae4f4	Factory	19	1
27	11	ed0d9403-1a79-44d3-bbc6-e27b13970d77	Factory	19	1
31	12	8602de33-6004-4d03-86e7-85d98846ba0c	Factory	20	1
29	12	222c10ea-2529-400a-a560-d7d92f65574c	Factory	20	1
28	12	d19b2377-c271-47b8-8c4d-454bdc2ee0a7	Factory	20	1
30	12	5184c87c-b049-4485-8515-ae2807c0b1bf	Factory	20	1
32	13	5be61975-f18c-4e74-b031-55f5573d30ae	Factory	21	1
34	13	aa0b00e5-7e98-47d6-b0df-5dbf3ef81fbd	Factory	21	1
33	13	914914aa-d202-4734-b948-d58dfd856e19	Factory	21	1
11	14	a8fe8d5c-a1dc-4dfc-b8fb-8170120faa0b	Factory	11	1
13	14	aacd2399-7e8f-4c3c-b127-9ea1582f2b7d	Factory	11	1
14	14	f7c4ee80-d16b-401e-a459-88f84d627554	Factory	11	1
12	14	79637f28-0905-4e84-900b-8eb1abab84fc	Factory	11	1
37	21	ad8d196a-6436-4452-91ce-2034776c9a8f	Warehouse	6	\N
38	22	9cdd433b-342d-4981-95ac-ba548b77cbfb	Warehouse	7	\N
39	22	ad87a411-3940-498d-869b-480f0173fcf3	Warehouse	7	\N
40	23	b97c337a-c52e-4a2c-9330-0863704eb0c7	Warehouse	8	\N
41	26	57910407-4b75-4190-b15d-0abac31c2e5d	Warehouse	9	\N
\.


--
-- Data for Name: mo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mo (id, date_created, date_done, bom_id, status) FROM stdin;
1	2023-07-09 17:12:57.027741-06	\N	8	In Progress
\.


--
-- Data for Name: po; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.po (id, date_created, status, supplier_id, received_date) FROM stdin;
1	2023-07-09 15:57:54.890477-06	Draft	2	\N
3	2023-07-09 16:21:39.195673-06	Completed	4	2023-07-09 17:26:49.632622
4	2023-07-09 16:21:56.578022-06	Completed	2	2023-07-09 17:29:28.378416
5	2023-07-09 17:34:34.184334-06	Completed	4	2023-07-09 17:34:59.34677
6	2023-07-09 17:47:40.785081-06	Completed	2	2023-07-09 17:48:59.248012
2	2023-07-09 16:00:49.900767-06	Completed	1	2023-07-09 17:59:54.92417
\.


--
-- Data for Name: po_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.po_line (id, po_id, product_id, quantity) FROM stdin;
1	1	16	1
2	1	17	1
3	1	18	3
4	1	19	1
5	1	27	1
6	2	21	1
7	2	22	2
8	2	23	1
9	2	26	1
10	3	2	10
11	3	14	4
12	4	4	1
13	4	5	1
14	4	6	4
15	4	7	1
16	4	8	1
17	4	9	2
18	4	10	1
19	4	11	2
20	4	12	4
21	4	13	3
22	5	1	1
23	6	3	1
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (id, name, description, price, is_assembly) FROM stdin;
1	TV Set	a TV	199.99	f
2	Tennis Ball	Yellow tennis ball for Tellyscope activation	2.99	f
4	Spring Mechanism	Compression spring for propelling tennis ball	8.99	f
5	Trigger Lever	Lever component for triggering mechanism	6.99	f
6	Mounting Bracket	Bracket component for triggering mechanism	3.99	f
7	Trigger Spring	Spring component for triggering mechanism	2.99	f
8	Telescoping Shaft	Metal or plastic tubes of various lengths for extension	39.99	f
9	Support Brackets	Metal brackets for supporting the assembly	14.99	f
10	Locking Mechanism	Mechanism for securing at desired length	9.99	f
11	Rail	Metal rail for guiding extension	19.99	f
12	Tube	Metal tube	7.99	f
13	Coupler	Coupler or connector to join tubes	4.99	f
14	Fastening Hardware	Various screws, nuts, bolts	5.99	f
15	Vacuum Motor	Powerful motor for suction	99.99	f
16	Teeth Attachment	Sharp metal teeth attachment for crumbs	19.99	f
17	Suction Hose	Flexible hose for suction	14.99	f
18	Dirt Collection Bag	Bag for collecting dirt and debris	8.99	f
19	Vacuum Handle	Handle for gripping and maneuvering the vacuum	12.99	f
20	On/Off Switch	Switch for controlling the vacuum's power	6.99	f
21	Wheels	Set of wheels for easy movement	24.99	f
22	Cracker Sensor	Sensor for detecting cracker crumbs	9.99	f
23	Dustpan and Brush	Cleaning tools for sweeping dirt	7.99	f
26	Power Cord	Electric cord for connecting to power source	16.99	f
27	Housing Casing	Outer casing for enclosing the internal components	29.99	f
34	Tellyscope	To activate the TV set without leaving his chair, Wallace launches a tennis ball into a hole in the wall. It triggers a mechanism that extends across the room on a telescoping shaft to reach the on/off and channel buttons. 	\N	t
3	Launcher Arm	Metal rod for launching tennis ball	12.99	f
36	525-Crackervac	To speed up Gromit's chores of sweeping, Wallace activates the 525 Crackervac, a vacuum cleaner with sharp metal teeth that can suck up cracker crumbs at high speed.	\N	t
\.


--
-- Data for Name: stock_move; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_move (id, inventory_item_id, source_location, destination_location, move_date) FROM stdin;
37	35	Warehouse	Factory	2023-07-09 17:50:47.517672-06
38	8	Warehouse	Factory	2023-07-09 17:50:47.524346-06
39	7	Warehouse	Factory	2023-07-09 17:50:47.526305-06
40	9	Warehouse	Factory	2023-07-09 17:50:47.527818-06
41	10	Warehouse	Factory	2023-07-09 17:50:47.529478-06
42	1	Warehouse	Factory	2023-07-09 17:50:47.531021-06
43	5	Warehouse	Factory	2023-07-09 17:50:47.53288-06
44	2	Warehouse	Factory	2023-07-09 17:50:47.534706-06
45	4	Warehouse	Factory	2023-07-09 17:50:47.5365-06
46	6	Warehouse	Factory	2023-07-09 17:50:47.538454-06
47	3	Warehouse	Factory	2023-07-09 17:50:47.540275-06
48	36	Warehouse	Factory	2023-07-09 17:50:47.543733-06
49	15	Warehouse	Factory	2023-07-09 17:50:47.54871-06
50	16	Warehouse	Factory	2023-07-09 17:50:47.553482-06
51	19	Warehouse	Factory	2023-07-09 17:50:47.558281-06
52	17	Warehouse	Factory	2023-07-09 17:50:47.560395-06
53	18	Warehouse	Factory	2023-07-09 17:50:47.561789-06
54	20	Warehouse	Factory	2023-07-09 17:50:47.563134-06
55	21	Warehouse	Factory	2023-07-09 17:50:47.566805-06
56	22	Warehouse	Factory	2023-07-09 17:50:47.572052-06
57	24	Warehouse	Factory	2023-07-09 17:50:47.57621-06
58	23	Warehouse	Factory	2023-07-09 17:50:47.578475-06
59	25	Warehouse	Factory	2023-07-09 17:50:47.581674-06
60	26	Warehouse	Factory	2023-07-09 17:50:47.585217-06
61	27	Warehouse	Factory	2023-07-09 17:50:47.58793-06
62	29	Warehouse	Factory	2023-07-09 17:50:47.591944-06
63	31	Warehouse	Factory	2023-07-09 17:50:47.593862-06
64	28	Warehouse	Factory	2023-07-09 17:50:47.595217-06
65	30	Warehouse	Factory	2023-07-09 17:50:47.596591-06
66	32	Warehouse	Factory	2023-07-09 17:50:47.600046-06
67	34	Warehouse	Factory	2023-07-09 17:50:47.60219-06
68	33	Warehouse	Factory	2023-07-09 17:50:47.603774-06
69	11	Warehouse	Factory	2023-07-09 17:50:47.607743-06
70	13	Warehouse	Factory	2023-07-09 17:50:47.60989-06
71	12	Warehouse	Factory	2023-07-09 17:50:47.611312-06
72	14	Warehouse	Factory	2023-07-09 17:50:47.612878-06
1	1	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
2	2	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
3	3	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
4	4	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
5	5	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
6	6	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
7	7	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
8	8	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
9	9	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
10	10	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
11	11	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
12	12	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
13	13	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
14	14	Supplier	Warehouse	2023-07-09 17:26:49.632622-06
15	15	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
16	16	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
17	17	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
18	18	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
19	19	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
20	20	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
21	21	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
22	22	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
23	23	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
24	24	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
25	25	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
26	26	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
27	27	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
28	28	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
29	29	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
30	30	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
31	31	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
32	32	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
33	33	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
34	34	Supplier	Warehouse	2023-07-09 17:29:28.378416-06
35	35	Supplier	Warehouse	2023-07-09 17:34:59.34677-06
36	36	Supplier	Warehouse	2023-07-09 17:48:59.248012-06
73	37	Supplier	Warehouse	2023-07-09 17:59:54.92417-06
74	38	Supplier	Warehouse	2023-07-09 17:59:54.92417-06
75	39	Supplier	Warehouse	2023-07-09 17:59:54.92417-06
76	40	Supplier	Warehouse	2023-07-09 17:59:54.92417-06
77	41	Supplier	Warehouse	2023-07-09 17:59:54.92417-06
\.


--
-- Data for Name: supplier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.supplier (id, name, contact) FROM stdin;
1	Preston Supplies	info@prestonsupplies.com
2	McGraw Industries	sales@mcgraw.com
4	Wendolynne's Market	ask@wm.com
\.


--
-- Name: bom_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bom_id_seq', 9, true);


--
-- Name: bom_line_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bom_line_id_seq', 73, true);


--
-- Name: inventory_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_item_id_seq', 41, true);


--
-- Name: mo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mo_id_seq', 1, true);


--
-- Name: po_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.po_id_seq', 6, true);


--
-- Name: po_line_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.po_line_id_seq', 23, true);


--
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_id_seq', 36, true);


--
-- Name: stock_move_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_move_id_seq', 77, true);


--
-- Name: supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.supplier_id_seq', 5, true);


--
-- Name: bom_line bom_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bom_line
    ADD CONSTRAINT bom_line_pkey PRIMARY KEY (id);


--
-- Name: bom bom_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bom
    ADD CONSTRAINT bom_pkey PRIMARY KEY (id);


--
-- Name: inventory_item inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_pkey PRIMARY KEY (id);


--
-- Name: mo mo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mo
    ADD CONSTRAINT mo_pkey PRIMARY KEY (id);


--
-- Name: po_line po_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.po_line
    ADD CONSTRAINT po_line_pkey PRIMARY KEY (id);


--
-- Name: po po_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.po
    ADD CONSTRAINT po_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: stock_move stock_move_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_move
    ADD CONSTRAINT stock_move_pkey PRIMARY KEY (id);


--
-- Name: supplier supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (id);


--
-- Name: po update_received_date_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_received_date_trigger BEFORE UPDATE ON public.po FOR EACH ROW EXECUTE FUNCTION public.update_received_date();


--
-- Name: bom_line bom_line_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bom_line
    ADD CONSTRAINT bom_line_bom_id_fkey FOREIGN KEY (bom_id) REFERENCES public.bom(id);


--
-- Name: bom_line bom_line_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bom_line
    ADD CONSTRAINT bom_line_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.product(id);


--
-- Name: bom bom_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bom
    ADD CONSTRAINT bom_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);


--
-- Name: inventory_item inventory_item_mo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_mo_id_fkey FOREIGN KEY (mo_id) REFERENCES public.mo(id);


--
-- Name: inventory_item inventory_item_po_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_po_line_id_fkey FOREIGN KEY (po_line_id) REFERENCES public.po_line(id);


--
-- Name: inventory_item inventory_item_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);


--
-- Name: mo mo_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mo
    ADD CONSTRAINT mo_bom_id_fkey FOREIGN KEY (bom_id) REFERENCES public.bom(id);


--
-- Name: po_line po_line_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.po_line
    ADD CONSTRAINT po_line_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.po(id);


--
-- Name: po_line po_line_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.po_line
    ADD CONSTRAINT po_line_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);


--
-- Name: po po_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.po
    ADD CONSTRAINT po_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.supplier(id);


--
-- Name: stock_move stock_move_inventory_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_move
    ADD CONSTRAINT stock_move_inventory_item_id_fkey FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id);


--
-- PostgreSQL database dump complete
--

