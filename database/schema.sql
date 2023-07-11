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

