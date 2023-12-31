PGDMP         3                {           mini_erp     15.3 (Ubuntu 15.3-1.pgdg20.04+1)     15.3 (Ubuntu 15.3-1.pgdg20.04+1) V    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16821    mini_erp    DATABASE     t   CREATE DATABASE mini_erp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';
    DROP DATABASE mini_erp;
                postgres    false                        3079    16822 	   uuid-ossp 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
    DROP EXTENSION "uuid-ossp";
                   false            �           0    0    EXTENSION "uuid-ossp"    COMMENT     W   COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';
                        false    2            b           1247    16834    location_type    TYPE     {   CREATE TYPE public.location_type AS ENUM (
    'Warehouse',
    'Factory',
    'Repair',
    'Supplier',
    'Customer'
);
     DROP TYPE public.location_type;
       public          postgres    false            e           1247    16846 	   mo_status    TYPE     �   CREATE TYPE public.mo_status AS ENUM (
    'Draft',
    'Pending',
    'Reserved',
    'In Progress',
    'Completed',
    'Cancelled'
);
    DROP TYPE public.mo_status;
       public          postgres    false            h           1247    16860    mo_status_temp    TYPE        CREATE TYPE public.mo_status_temp AS ENUM (
    'Draft',
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled'
);
 !   DROP TYPE public.mo_status_temp;
       public          postgres    false            k           1247    16872 	   po_status    TYPE     �   CREATE TYPE public.po_status AS ENUM (
    'Draft',
    'Pending Approval',
    'Approved',
    'In Progress',
    'Completed',
    'Cancelled'
);
    DROP TYPE public.po_status;
       public          postgres    false            �            1255    16885    update_received_date()    FUNCTION     �   CREATE FUNCTION public.update_received_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.status = 'Completed' THEN
    NEW.received_date := NOW();
  END IF;
  RETURN NEW;
END;
$$;
 -   DROP FUNCTION public.update_received_date();
       public          postgres    false            �            1259    16886    bom    TABLE     M   CREATE TABLE public.bom (
    id integer NOT NULL,
    product_id integer
);
    DROP TABLE public.bom;
       public         heap    postgres    false            �            1259    16889 
   bom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.bom_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE public.bom_id_seq;
       public          postgres    false    215                        0    0 
   bom_id_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE public.bom_id_seq OWNED BY public.bom.id;
          public          postgres    false    216            �            1259    16890    bom_line    TABLE     ~   CREATE TABLE public.bom_line (
    id integer NOT NULL,
    bom_id integer,
    component_id integer,
    quantity integer
);
    DROP TABLE public.bom_line;
       public         heap    postgres    false            �            1259    16893    bom_line_id_seq    SEQUENCE     �   CREATE SEQUENCE public.bom_line_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.bom_line_id_seq;
       public          postgres    false    217                       0    0    bom_line_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.bom_line_id_seq OWNED BY public.bom_line.id;
          public          postgres    false    218            �            1259    16894    inventory_item    TABLE     �   CREATE TABLE public.inventory_item (
    id integer NOT NULL,
    product_id integer,
    serial_number uuid DEFAULT public.uuid_generate_v4(),
    location public.location_type,
    po_line_id integer,
    mo_id integer
);
 "   DROP TABLE public.inventory_item;
       public         heap    postgres    false    2    866            �            1259    16898    inventory_item_id_seq    SEQUENCE     �   CREATE SEQUENCE public.inventory_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.inventory_item_id_seq;
       public          postgres    false    219                       0    0    inventory_item_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.inventory_item_id_seq OWNED BY public.inventory_item.id;
          public          postgres    false    220            �            1259    16899    mo    TABLE     �  CREATE TABLE public.mo (
    id integer NOT NULL,
    date_created timestamp with time zone DEFAULT now(),
    date_done timestamp with time zone,
    bom_id integer,
    status public.mo_status DEFAULT 'Draft'::public.mo_status,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['Draft'::public.mo_status, 'Pending'::public.mo_status, 'Reserved'::public.mo_status, 'In Progress'::public.mo_status, 'Completed'::public.mo_status, 'Cancelled'::public.mo_status])))
);
    DROP TABLE public.mo;
       public         heap    postgres    false    869    869    869            �            1259    16905 	   mo_id_seq    SEQUENCE     �   CREATE SEQUENCE public.mo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.mo_id_seq;
       public          postgres    false    221                       0    0 	   mo_id_seq    SEQUENCE OWNED BY     7   ALTER SEQUENCE public.mo_id_seq OWNED BY public.mo.id;
          public          postgres    false    222            �            1259    16906    po    TABLE     �  CREATE TABLE public.po (
    id integer NOT NULL,
    date_created timestamp with time zone DEFAULT now(),
    status public.po_status DEFAULT 'Draft'::public.po_status,
    supplier_id integer,
    received_date timestamp without time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['Draft'::public.po_status, 'Pending Approval'::public.po_status, 'Approved'::public.po_status, 'In Progress'::public.po_status, 'Completed'::public.po_status, 'Cancelled'::public.po_status])))
);
    DROP TABLE public.po;
       public         heap    postgres    false    875    875    875            �            1259    16912 	   po_id_seq    SEQUENCE     �   CREATE SEQUENCE public.po_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.po_id_seq;
       public          postgres    false    223                       0    0 	   po_id_seq    SEQUENCE OWNED BY     7   ALTER SEQUENCE public.po_id_seq OWNED BY public.po.id;
          public          postgres    false    224            �            1259    16913    po_line    TABLE     z   CREATE TABLE public.po_line (
    id integer NOT NULL,
    po_id integer,
    product_id integer,
    quantity integer
);
    DROP TABLE public.po_line;
       public         heap    postgres    false            �            1259    16916    po_line_id_seq    SEQUENCE     �   CREATE SEQUENCE public.po_line_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.po_line_id_seq;
       public          postgres    false    225                       0    0    po_line_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.po_line_id_seq OWNED BY public.po_line.id;
          public          postgres    false    226            �            1259    16917    product    TABLE     �   CREATE TABLE public.product (
    id integer NOT NULL,
    name character varying(255),
    description text,
    price numeric(10,2),
    is_assembly boolean DEFAULT false
);
    DROP TABLE public.product;
       public         heap    postgres    false            �            1259    16923    product_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public          postgres    false    227                       0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
          public          postgres    false    228            �            1259    16924 
   stock_move    TABLE     �   CREATE TABLE public.stock_move (
    id integer NOT NULL,
    inventory_item_id integer,
    source_location public.location_type,
    destination_location public.location_type,
    move_date timestamp with time zone DEFAULT now()
);
    DROP TABLE public.stock_move;
       public         heap    postgres    false    866    866            �            1259    16928    stock_move_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stock_move_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.stock_move_id_seq;
       public          postgres    false    229                       0    0    stock_move_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.stock_move_id_seq OWNED BY public.stock_move.id;
          public          postgres    false    230            �            1259    16929    supplier    TABLE        CREATE TABLE public.supplier (
    id integer NOT NULL,
    name character varying(255),
    contact character varying(255)
);
    DROP TABLE public.supplier;
       public         heap    postgres    false            �            1259    16934    supplier_id_seq    SEQUENCE     �   CREATE SEQUENCE public.supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.supplier_id_seq;
       public          postgres    false    231                       0    0    supplier_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.supplier_id_seq OWNED BY public.supplier.id;
          public          postgres    false    232            )           2604    16935    bom id    DEFAULT     `   ALTER TABLE ONLY public.bom ALTER COLUMN id SET DEFAULT nextval('public.bom_id_seq'::regclass);
 5   ALTER TABLE public.bom ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    215            *           2604    16936    bom_line id    DEFAULT     j   ALTER TABLE ONLY public.bom_line ALTER COLUMN id SET DEFAULT nextval('public.bom_line_id_seq'::regclass);
 :   ALTER TABLE public.bom_line ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    217            +           2604    16937    inventory_item id    DEFAULT     v   ALTER TABLE ONLY public.inventory_item ALTER COLUMN id SET DEFAULT nextval('public.inventory_item_id_seq'::regclass);
 @   ALTER TABLE public.inventory_item ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    220    219            -           2604    16938    mo id    DEFAULT     ^   ALTER TABLE ONLY public.mo ALTER COLUMN id SET DEFAULT nextval('public.mo_id_seq'::regclass);
 4   ALTER TABLE public.mo ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    221            0           2604    16939    po id    DEFAULT     ^   ALTER TABLE ONLY public.po ALTER COLUMN id SET DEFAULT nextval('public.po_id_seq'::regclass);
 4   ALTER TABLE public.po ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    224    223            3           2604    16940 
   po_line id    DEFAULT     h   ALTER TABLE ONLY public.po_line ALTER COLUMN id SET DEFAULT nextval('public.po_line_id_seq'::regclass);
 9   ALTER TABLE public.po_line ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    226    225            4           2604    16941 
   product id    DEFAULT     h   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    228    227            6           2604    16942    stock_move id    DEFAULT     n   ALTER TABLE ONLY public.stock_move ALTER COLUMN id SET DEFAULT nextval('public.stock_move_id_seq'::regclass);
 <   ALTER TABLE public.stock_move ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    230    229            8           2604    16943    supplier id    DEFAULT     j   ALTER TABLE ONLY public.supplier ALTER COLUMN id SET DEFAULT nextval('public.supplier_id_seq'::regclass);
 :   ALTER TABLE public.supplier ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    232    231            �          0    16886    bom 
   TABLE DATA           -   COPY public.bom (id, product_id) FROM stdin;
    public          postgres    false    215   1b       �          0    16890    bom_line 
   TABLE DATA           F   COPY public.bom_line (id, bom_id, component_id, quantity) FROM stdin;
    public          postgres    false    217   Xb       �          0    16894    inventory_item 
   TABLE DATA           d   COPY public.inventory_item (id, product_id, serial_number, location, po_line_id, mo_id) FROM stdin;
    public          postgres    false    219   �b       �          0    16899    mo 
   TABLE DATA           I   COPY public.mo (id, date_created, date_done, bom_id, status) FROM stdin;
    public          postgres    false    221   Sg       �          0    16906    po 
   TABLE DATA           R   COPY public.po (id, date_created, status, supplier_id, received_date) FROM stdin;
    public          postgres    false    223   �g       �          0    16913    po_line 
   TABLE DATA           B   COPY public.po_line (id, po_id, product_id, quantity) FROM stdin;
    public          postgres    false    225   _h       �          0    16917    product 
   TABLE DATA           L   COPY public.product (id, name, description, price, is_assembly) FROM stdin;
    public          postgres    false    227   �h       �          0    16924 
   stock_move 
   TABLE DATA           m   COPY public.stock_move (id, inventory_item_id, source_location, destination_location, move_date) FROM stdin;
    public          postgres    false    229   �l       �          0    16929    supplier 
   TABLE DATA           5   COPY public.supplier (id, name, contact) FROM stdin;
    public          postgres    false    231   o       	           0    0 
   bom_id_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.bom_id_seq', 9, true);
          public          postgres    false    216            
           0    0    bom_line_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.bom_line_id_seq', 73, true);
          public          postgres    false    218                       0    0    inventory_item_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.inventory_item_id_seq', 41, true);
          public          postgres    false    220                       0    0 	   mo_id_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.mo_id_seq', 1, true);
          public          postgres    false    222                       0    0 	   po_id_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.po_id_seq', 6, true);
          public          postgres    false    224                       0    0    po_line_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.po_line_id_seq', 23, true);
          public          postgres    false    226                       0    0    product_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.product_id_seq', 36, true);
          public          postgres    false    228                       0    0    stock_move_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.stock_move_id_seq', 77, true);
          public          postgres    false    230                       0    0    supplier_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.supplier_id_seq', 5, true);
          public          postgres    false    232            >           2606    16945    bom_line bom_line_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.bom_line
    ADD CONSTRAINT bom_line_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.bom_line DROP CONSTRAINT bom_line_pkey;
       public            postgres    false    217            <           2606    16947    bom bom_pkey 
   CONSTRAINT     J   ALTER TABLE ONLY public.bom
    ADD CONSTRAINT bom_pkey PRIMARY KEY (id);
 6   ALTER TABLE ONLY public.bom DROP CONSTRAINT bom_pkey;
       public            postgres    false    215            @           2606    16949 "   inventory_item inventory_item_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.inventory_item DROP CONSTRAINT inventory_item_pkey;
       public            postgres    false    219            B           2606    16951 
   mo mo_pkey 
   CONSTRAINT     H   ALTER TABLE ONLY public.mo
    ADD CONSTRAINT mo_pkey PRIMARY KEY (id);
 4   ALTER TABLE ONLY public.mo DROP CONSTRAINT mo_pkey;
       public            postgres    false    221            F           2606    16953    po_line po_line_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.po_line
    ADD CONSTRAINT po_line_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.po_line DROP CONSTRAINT po_line_pkey;
       public            postgres    false    225            D           2606    16955 
   po po_pkey 
   CONSTRAINT     H   ALTER TABLE ONLY public.po
    ADD CONSTRAINT po_pkey PRIMARY KEY (id);
 4   ALTER TABLE ONLY public.po DROP CONSTRAINT po_pkey;
       public            postgres    false    223            H           2606    16957    product product_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pkey;
       public            postgres    false    227            J           2606    16959    stock_move stock_move_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.stock_move
    ADD CONSTRAINT stock_move_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.stock_move DROP CONSTRAINT stock_move_pkey;
       public            postgres    false    229            L           2606    16961    supplier supplier_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.supplier DROP CONSTRAINT supplier_pkey;
       public            postgres    false    231            X           2620    16962    po update_received_date_trigger    TRIGGER     �   CREATE TRIGGER update_received_date_trigger BEFORE UPDATE ON public.po FOR EACH ROW EXECUTE FUNCTION public.update_received_date();
 8   DROP TRIGGER update_received_date_trigger ON public.po;
       public          postgres    false    243    223            N           2606    16963    bom_line bom_line_bom_id_fkey    FK CONSTRAINT     y   ALTER TABLE ONLY public.bom_line
    ADD CONSTRAINT bom_line_bom_id_fkey FOREIGN KEY (bom_id) REFERENCES public.bom(id);
 G   ALTER TABLE ONLY public.bom_line DROP CONSTRAINT bom_line_bom_id_fkey;
       public          postgres    false    217    3388    215            O           2606    16968 #   bom_line bom_line_component_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.bom_line
    ADD CONSTRAINT bom_line_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.product(id);
 M   ALTER TABLE ONLY public.bom_line DROP CONSTRAINT bom_line_component_id_fkey;
       public          postgres    false    217    3400    227            M           2606    16973    bom bom_product_id_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY public.bom
    ADD CONSTRAINT bom_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);
 A   ALTER TABLE ONLY public.bom DROP CONSTRAINT bom_product_id_fkey;
       public          postgres    false    215    227    3400            P           2606    16978 (   inventory_item inventory_item_mo_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_mo_id_fkey FOREIGN KEY (mo_id) REFERENCES public.mo(id);
 R   ALTER TABLE ONLY public.inventory_item DROP CONSTRAINT inventory_item_mo_id_fkey;
       public          postgres    false    221    3394    219            Q           2606    16983 -   inventory_item inventory_item_po_line_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_po_line_id_fkey FOREIGN KEY (po_line_id) REFERENCES public.po_line(id);
 W   ALTER TABLE ONLY public.inventory_item DROP CONSTRAINT inventory_item_po_line_id_fkey;
       public          postgres    false    219    225    3398            R           2606    16988 -   inventory_item inventory_item_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);
 W   ALTER TABLE ONLY public.inventory_item DROP CONSTRAINT inventory_item_product_id_fkey;
       public          postgres    false    219    3400    227            S           2606    16993    mo mo_bom_id_fkey    FK CONSTRAINT     m   ALTER TABLE ONLY public.mo
    ADD CONSTRAINT mo_bom_id_fkey FOREIGN KEY (bom_id) REFERENCES public.bom(id);
 ;   ALTER TABLE ONLY public.mo DROP CONSTRAINT mo_bom_id_fkey;
       public          postgres    false    3388    215    221            U           2606    16998    po_line po_line_po_id_fkey    FK CONSTRAINT     t   ALTER TABLE ONLY public.po_line
    ADD CONSTRAINT po_line_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.po(id);
 D   ALTER TABLE ONLY public.po_line DROP CONSTRAINT po_line_po_id_fkey;
       public          postgres    false    223    225    3396            V           2606    17003    po_line po_line_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.po_line
    ADD CONSTRAINT po_line_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);
 I   ALTER TABLE ONLY public.po_line DROP CONSTRAINT po_line_product_id_fkey;
       public          postgres    false    3400    227    225            T           2606    17008    po po_supplier_id_fkey    FK CONSTRAINT     |   ALTER TABLE ONLY public.po
    ADD CONSTRAINT po_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.supplier(id);
 @   ALTER TABLE ONLY public.po DROP CONSTRAINT po_supplier_id_fkey;
       public          postgres    false    223    231    3404            W           2606    17013 ,   stock_move stock_move_inventory_item_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stock_move
    ADD CONSTRAINT stock_move_inventory_item_id_fkey FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id);
 V   ALTER TABLE ONLY public.stock_move DROP CONSTRAINT stock_move_inventory_item_id_fkey;
       public          postgres    false    3392    229    219            �      x�3�46��46����� �      �   {   x��� D�3�D�^�ٟ��]�gcq,�,�(РD׶��YI��A����A��3��^v�BZ,�x�[(P��ʻ�2%#\��4�w��w(�#�q(�����(eߏ�� =!F      �   `  x�]��n�7�����@")�|��iӜF7"�r)����������efhiO}��ؖ�|�!]�U�������ױ�����S?��gq�i�4rLR��P�*���}���Z@�?���iN��&��x�$�F?j?߱ %1Z�}��6H���=��N�=ǰ�)���u�&��ڍ�`#݃u���DP>��cv����.N��q���=s��T��̑�f@Yg�U�|���%������3��͐���S��t�i��o}�f��+�-�U���0::Z���Va�Fq�Z�SPaYF���n�p�z�|������P��
i�$O_��u-aL�/�<]s�ES�Ce����2KhQ��1l�o�>;���3��SoB~�(O�A7�y��J���=&�FN9�������D]i����Z<����\�2S�*���L͹�,ɽ��Q/f��lV��Al,-Z��(��+�_>1.�b�:��=�/(d��2k�n���k~��^�+���Bx�ɨ��5X�1C+u�ʝ4��.T\�67[_X������;�̆"�������m�Z�_L�x��ۼ�.�`�l��v�/�]L����)N�b!ElP�)����9�ްvEv$B ��8�f�ΈO����/�R���<[�����4&�nKGS����]�첡Z�:�Ɇ���t�&���6��I���^x�德��B��}����;.�̫�3������igo������z#͌�i��/E�6�����wA�U�F����J���0�=��7������5�����HBL�Fٰ�� Kpz�1�,�4������ؤ�gB^s�7N.����	�\��|�F��9,���7�hԍ:w�S���v\���ON>���w�C;������!�<m�qz��1;vo��zh :���"������*b�N%
�w\)JA�g�1�t����}��X}G����p����*�f}��>�<��篃P��ۇ������$��I z��9"�l͜/�}�qI�iCq?θ䆶�z�RMr���Zn�OD��Z���1xQ��8�/z&N��$.3��pWU�.8|�t�mS�p�T(��2.�㗏��� g5�      �   >   x�3�4202�50�5�T04�24�25�302771�50������S(�O/J-.����� +��      �   �   x�}�;jAD��S�j���Ԏ}%K������n�cT�U<������D��>=�V��v�����>���'�!Sxj#�G�}����.����C2�Ĵ�P	���,9bd���B�2��Tۄ\�j��lIoT�L�ųM�YNů�X��"�e�>��2������8� �x=T�      �   u   x���	1C�o��%���e��c�` '6���ܑ*�6n���,P^��(�:���=�99�qe��1�^6�2|�^-�lJ̸�ĉ�=��a'z��'Eܐ_h"]��I��1      �   �  x��UMs9=7�B�\�$3l�1I�[e��ʩ��E���X#M���n}�:�@裟�^�n�<�5�b��r9].a?ia���^�I��?�ڞD�K[Z{�Ć�_��#
�B���ڌp���� Qu��X�at�=�>o2��Ak�����8sظ�p@'��ҷPe��B>����E�_���&�ޝ�ꅨ��w@f����L�r��"�-	�����u'�1H-X-}�q�^ؽ8J���Fs�O����a�`V���uG�Be��LS��g��e�{�����|��^ަ��+C����b��w�+O�򔦁e����~��C�wwy{S�aĶ0q�);32J5庌,��Ơ
���mo�XPI\���v/��$�s��+�'%L��������9�R1��:�cO��Q���E@��]k�YP.1t�cRu�(�n��'2iS�7�rq����]���#|����j���zN�-|�)�+�5��;y �d��L�w|L��j�z_�YV��������1��i0���1�Mqr������^�O}P䡼�gK-�C�y1���$��v��5��)Ͳ˥%폘dm���U�4 ����P��r��]{�>EFi�;}+�2�%X[��'ı
X��.�%Hw��Ϭ��JU4��M����h
o�SM�{��B>��<�S��4ɬ���W�zCۆ�tn/�Bfv��[;/�H��$��t6�QydЎz*�s��Wj�R��2�Q��o�:]M��B��H�'Z���Bmornot�zB*�m(g�OQ��A�G���<�=�!G:h�{K^��0�Aj_1k�T���!Lf���G7�c���ǯ�ի�����;�FV̏H�+��Og�>�cm�ˍ�z�"T�7�"4qA�"z��B���,=���$�9�����~kUn�]��ۦ����d2�	�Ғ�      �   i  x���M��1���)�@��'��pl،P%��fT���'!�6ؕ�}��yb�p��O�۷�ן7��������������v��*v�hjtnzb�B$,�����[��4i�}A����f!�F� �t��|�4#�V����!ݽS�4��eA!D�F�+9p���1/j ��'n���KE�|	�È�G��w�0"��6��ӯC�|,*�H;���n�w�����UW���F��PZA��>��}2��S@i3�V3����Nh�B��%����Pڧ�C�d��mv]}�0#���s���ih��E)p�m��ɮ13�fh�%���Țo���8fF���Z�e14��~�3#�D�u[3#�$߻'J��ח��o���!ҫ��2)�R�`
���)C=6c�+�Y�24#L�F�Pd���1���1���1�O���Խ�������+��c/�4��1�������E^���e,�?e,9b8@���u^�dF�:�g�c:s@����\��Le,v:?`I�~�����%���K"C����+',a��q�oQ[�(�W8!���H����8ZB�>�].�d�1��%9Rq��"GJA�)Ir��\N��o0�	�      �   k   x�-ʽ
�  ��|
����ܢ!ZZĮ��ψ޾���+���ɓ���+�^�O���x'JhM�!�vN�ɬ-�rf��MH��'f,[7L�yS�{Ø!.&�)�     