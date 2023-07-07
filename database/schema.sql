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
CREATE TYPE mo_status AS ENUM ('Draft', 'Pending', 'In Progress', 'Completed', 'Cancelled');

-- Create the mo table
CREATE TABLE mo (
  id serial PRIMARY KEY,
  date_created timestamptz DEFAULT now(),
  date_done timestamptz,
  bom_id integer REFERENCES bom (id),
  status mo_status DEFAULT 'Draft'::mo_status,
  CONSTRAINT valid_status CHECK (status = ANY (ARRAY['Draft'::mo_status, 'Pending'::mo_status, 'Reserved'::mo_status, 'In Progress'::mo_status, 'Completed'::mo_status, 'Cancelled'::mo_status]))
);


-- Define the location_type enum 
CREATE TYPE location_type AS ENUM ('Warehouse', 'Factory', 'Repair' );

-- Create the supplier table
CREATE TABLE supplier (
  id serial PRIMARY KEY,
  name varchar(255),
  email varchar(255)
);

-- Define the purchase_status enum type
CREATE TYPE po_status AS ENUM ('Draft', 'Pending Approval', 'Approved', 'In Progress', 'Completed', 'Cancelled');

-- Create the purchase table
CREATE TABLE po (
  id serial PRIMARY KEY,
  supplier_id integer REFERENCES supplier (id),
  created_date timestamptz DEFAULT now(),
  received_date timestamptz,
  status po_status DEFAULT 'Draft',
  CONSTRAINT valid_status CHECK (status = ANY (ARRAY['Draft'::po_status, 'Pending Approval'::po_status, 'Approved'::po_status, 'In Progress'::po_status, 'Completed'::po_status, 'Cancelled'::po_status]))
);

-- Create the purchase_line table
CREATE TABLE po_line (
  id serial PRIMARY KEY,
  po_id integer REFERENCES po (id),
  product_id integer REFERENCES product (id),
  inventory_item_id integer REFERENCES inventory_item (id),
  quantity integer
);

-- Create the inventory_item table
CREATE TABLE inventory_item (
  id serial PRIMARY KEY,
  product_id integer REFERENCES product (id),
  po_line_id integer REFERENCES po_line (id),
  serial_number varchar(255),
  location location_type
);

-- Create the stock_move table
CREATE TABLE stock_move (
  id serial PRIMARY KEY,
  inventory_item_id integer REFERENCES inventory_item (id),
  source_location location_type,
  destination_location location_type,
  move_date timestamptz DEFAULT now()
);

CREATE OR REPLACE FUNCTION update_received_date()
  RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'Completed' THEN
    NEW.received_date := NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_received_date_trigger
  BEFORE UPDATE ON po
  FOR EACH ROW
  EXECUTE FUNCTION update_received_date();