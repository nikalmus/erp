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

-- Create the mo table
CREATE TABLE mo (
  id serial PRIMARY KEY,
  name varchar(255),
  description text,
  date_created date,
  bom_id integer REFERENCES bom (id),
  status mo_status
);

-- Define the mo_status enum type
CREATE TYPE mo_status AS ENUM ('Pending', 'In Progress', 'Completed', 'Cancelled');

-- Add a check constraint for valid status values in mo table
ALTER TABLE mo ADD CONSTRAINT valid_status CHECK (status = ANY (ARRAY['Pending'::mo_status, 'In Progress'::mo_status, 'Completed'::mo_status, 'Cancelled'::mo_status]));
