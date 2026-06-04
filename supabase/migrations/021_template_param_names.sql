-- ============================================================
-- message_templates: named variable parameter columns
--
-- Meta's newer template API supports named variables in addition
-- to the legacy positional {{1}}, {{2}} syntax. Named templates
-- use identifiers like {{name}}, {{order_id}} and the send API
-- requires `parameter_name` on each text parameter so Meta can
-- map the value to the right placeholder.
--
-- Adds two columns:
--   body_param_names  text[]  Ordered list of variable names from
--                             the body component, e.g. ['name',
--                             'order_id']. NULL for positional-only
--                             templates ({{1}} style) and static
--                             templates with no variables.
--   header_param_name text    Variable name for a TEXT header with
--                             a single named variable. NULL when the
--                             header is static, media, or positional.
-- ============================================================

ALTER TABLE message_templates
  ADD COLUMN IF NOT EXISTS body_param_names  text[]  DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS header_param_name text    DEFAULT NULL;

COMMENT ON COLUMN message_templates.body_param_names IS
  'Ordered named-variable identifiers for the body component (e.g. [''name'', ''order_id'']). NULL for positional {{N}} or no-variable templates.';

COMMENT ON COLUMN message_templates.header_param_name IS
  'Named-variable identifier for a TEXT header with a single named variable. NULL for media headers, static text headers, or positional {{1}} headers.';
