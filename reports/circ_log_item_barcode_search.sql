--metadb:function circ_log_item_barcode_search

DROP FUNCTION IF EXISTS circ_log_item_barcode_search;

CREATE FUNCTION circ_log_item_barcode_search(
    ibarcode TEXT DEFAULT ''
    timezone TEXT DEFAULT 'America/Chicago')
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
SELECT cl.jsonb->>'userBarcode' AS user_barcode,
  items->>'itemBarcode' AS item_barcode,
  cl.jsonb->>'object' AS object,
  cl.jsonb->>'action' AS action,
  (cl.jsonb->>'date')::TIMESTAMPTZ AT TIME ZONE timezone AS date,
  spt.name AS service_point,
  cl.jsonb->>'source' AS source,
  cl.jsonb->>'description' AS description
FROM folio_audit.circulation_logs cl
CROSS JOIN jsonb_array_elements(cl.jsonb->'items') AS items
LEFT JOIN folio_inventory.service_point__t spt ON spt.id::text = cl.jsonb->>'servicePointId'
WHERE items->>'itemBarcode' = ibarcode
ORDER BY (cl.jsonb->>'date')::TIMESTAMPTZ DESC
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
