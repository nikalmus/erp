-- Create the product table
CREATE TABLE product (
  id serial PRIMARY KEY,
  name varchar(255),
  description text,
  price numeric(10,2),
  is_assembly boolean
);

-- Create the bom table
CREATE TABLE bom (
  id serial PRIMARY KEY,
  product_id integer REFERENCES product (id)
);

-- Create the bom_line table
CREATE TABLE bom_line (
  id serial PRIMARY KEY,
  bom_id integer REFERENCES bom (id),
  component_id integer REFERENCES product (id),
  quantity integer
);

-- Define the mo_status enum 
CREATE TYPE mo_status AS ENUM ('Pending', 'In Progress', 'Completed', 'Cancelled');

-- Create the mo table
CREATE TABLE mo (
  id serial PRIMARY KEY,
  description text,
  date_created timestamptz DEFAULT now(),
  date_done timestamptz,
  bom_id integer REFERENCES bom (id),
  status mo_status,
  CONSTRAINT date_created_read_only CHECK (date_created = DEFAULT)
);

-- Add a check constraint for valid status values in mo table
ALTER TABLE mo ADD CONSTRAINT valid_status CHECK (status = ANY (ARRAY['Pending'::mo_status, 'In Progress'::mo_status, 'Completed'::mo_status, 'Cancelled'::mo_status]));

-- Define the location_type enum 
CREATE TYPE location_type AS ENUM ('Warehouse', 'Factory', 'Repair' );

-- Define the stock_move_type enum 
CREATE TYPE stock_move_type AS ENUM ('In', 'Out');

-- Create the inventory_item table
CREATE TABLE inventory_item (
  id serial PRIMARY KEY,
  product_id integer REFERENCES product (id),
  serial_number varchar(255),
  qr_code varchar(255),
  location location_type
);

-- Create the stock_move table
CREATE TABLE stock_move (
  id serial PRIMARY KEY,
  inventory_item_id integer REFERENCES inventory_item (id),
  move_type stock_move_type,
  source_location location_type,
  destination_location location_type,
  move_date timestamptz DEFAULT now()
);

-- Create the supplier table
CREATE TABLE supplier (
  id serial PRIMARY KEY,
  name varchar(255),
  email varchar(255)
);

-- Define the purchase_status enum type
CREATE TYPE purchase_status AS ENUM ('Draft', 'Pending Approval', 'Approved', 'In Progress', 'Completed', 'Cancelled');

-- Create the purchase table
CREATE TABLE purchase (
  id serial PRIMARY KEY,
  supplier_id integer REFERENCES supplier (id),
  purchase_date date,
  status purchase_status
);

-- Create the purchase_line table
CREATE TABLE purchase_line (
  id serial PRIMARY KEY,
  purchase_id integer REFERENCES purchase (id),
  product_id integer REFERENCES product (id),
  quantity integer,
  unit_price numeric(10,2)
);


