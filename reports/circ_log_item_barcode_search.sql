--metadb:function circ_log_item_barcode_search

DROP FUNCTION IF EXISTS circ_log_item_barcode_search;

CREATE FUNCTION circ_log_item_barcode_search(
    ibarcode TEXT DEFAULT '')
RETURNS TABLE(
    user_barcode TEXT,
    item_barcode TEXT,
    object TEXT,
    action TEXT,
    date TIMESTAMPTZ,
    service_point TEXT,
    source TEXT,
    description TEXT)
AS $$
select cl.jsonb->>'userBarcode' as user_barcode,
  items->>'itemBarcode' as item_barcode,
  cl.jsonb->>'object' as object,
  cl.jsonb->>'action' as action,
  (cl.jsonb->>'date')::timestamptz at time zone 'America/Chicago' as date,
  spt.name as service_point,
  cl.jsonb->>'source' as source,
  cl.jsonb->>'description' as description
from folio_audit.circulation_logs cl
cross join jsonb_array_elements(cl.jsonb->'items') as items
left join folio_inventory.service_point__t spt on spt.id::text = cl.jsonb->>'servicePointId'
where items->>'itemBarcode' = ibarcode
order by (cl.jsonb->>'date')::timestamptz desc
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
