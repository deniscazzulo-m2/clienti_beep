INSERT dbo.[CliOrdImp_Pers](origin, id, number, order_key, cart_hash, parent_id, status, version, link_self, customer_id, customer_email, customer_first_name, customer_last_name, customer_role, customer_note, customer_ip_address, customer_user_agent, link_customer, needs_payment, needs_processing, payment_method, payment_method_title, currency, transaction_id, payment_url, total, subtotal, discount_total, shipping_total, total_tax, cart_tax, discount_tax, shipping_tax, prices_include_tax, tax_id, tax_rate_code, tax_rate_id, tax_label, tax_compound, tax_tax_total, tax_rate_percent, total_line_items_quantity, billing_first_name, billing_last_name, billing_company, billing_address_1, billing_address_2, billing_city, billing_state, billing_postcode, billing_country, billing_email, billing_phone, shipping_first_name, shipping_last_name, shipping_company, shipping_address_1, shipping_address_2, shipping_city, shipping_state, shipping_postcode, shipping_country, shipping_phone, shipping_method_title, fee_name, fee_tax_class, fee_total, fee_total_tax, coupon_code, coupon_discount, coupon_discount_tax, coupon_discount_type, coupon_nominal_amount, coupon_free_shipping, created_via, is_editable, date_created, date_created_gmt, date_modified, date_modified_gmt, date_completed, date_completed_gmt, date_paid, date_paid_gmt, Uniq, AnaCod)
VALUES(
    '{origin}', -- si aspetta 'promoser', 'gagliardetti' o 'adunata' in base a quale invia i dati
    {id}, -- .id
    '{number}', -- .number, .order_number x GAGLIARDETTI
    '{order_key}', -- .order_key, null x GAGLIARDETTI
    '{cart_hash}', -- .cart_hash, null x GAGLIARDETTI
    {parent_id}, -- .parent_id, null x GAGLIARDETTI
    '{status}', -- .status
    '{version}', -- .version, null x GAGLIARDETTI
    '{link_self}', -- ._links.self[0].href, .view_order_url x GAGLIARDETTI
    {customer_id}, -- .customer_id
    '{customer_email}', --null, .customer.email x GAGLIARDETTI
    '{customer_first_name}', --null, .custome.first_name x GAGLIARDETTI
    '{customer_last_name}', --null, .customer.last_name x GAGLIARDETTI
    '{customer_role}', --null, .customer.role x GAGLIARDETTI
    '{customer_note}', -- .customer_note
    '{customer_ip_address}', -- .customer_ip_address
    '{customer_user_agent}', -- .customer_user_agent
    '{link_customer}', -- ._links.customer[0].href, .customer.avatar_url x GAGLIARDETTI
    {needs_payment}, -- .needs_payment, .payment_details.paid x GAGLIARDETTI(deve essere invertito, quindi 0 -> 1 e viceversa)
    {needs_processing}, -- .needs_processing, null x GAGLIARDETTI
    '{payment_method}', -- .payment_method, .payment_details.method_id x GAGLIARDETTI
    '{payment_method_title}', -- .payment_method_title, .payment_details.method_title x GAGLIARDETTI
    '{currency}', -- .currency
    {transaction_id}, -- .transaction_id, null x GAGLIARDETTI
    '{payment_url}', -- .payment_url, null x GAGLIARDETTI
    '{total}', -- .total
    '{subtotal}', --null, .subtotal x GAGLIARDETTI
    '{discount_total}', -- .discount_total, .total_discount x GAGLIARDETTI
    '{shipping_total}', -- .shipping_total, .total_shipping x GAGLIARDETTI
    '{total_tax}', -- .total_tax
    '{cart_tax}', -- .cart_tax
    '{discount_tax}', -- .discount_tax, null x GAGLIARDETTI
    '{shipping_tax}', -- .shipping_tax, null x GAGLIARDETTI
    {prices_include_tax}, -- .prices_include_tax
    {tax_id}, -- .tax_lines[0].id, null x ADUNATA
    '{tax_rate_code}', -- .tax_lines[0].rate_code x PROMOSER, .tax_lines[0].code x GAGLIARDETTI, null x ADUNATA
    {tax_rate_id}, -- .tax_lines[0].rate_id, null x ADUNATA
    '{tax_label}', -- .tax_lines[0].label, null x ADUNATA
    {tax_compound}, -- .tax_lines[0].compound, null x ADUNATA
    '{tax_tax_total}', -- .tax_lines[0].tax_total x PROMOSER, .tax_lines[0].total x GAGLIARDETTI, null x ADUNATA
    {tax_rate_percent}, -- null, .tax_lines[0].rate_percent x PROMOSER
    {total_line_items_quantity}, -- null, .total_line_items_quantity x GAGLIARDETTI
    '{billing_first_name}', -- .billing.first_name
    '{billing_last_name}', -- .billing.last_name
    '{billing_company}', -- .billing.company
    '{billing_address_1}', -- .billing.address_1
    '{billing_address_2}', -- .billing.address_2
    '{billing_city}', -- .billing.city
    '{billing_state}', -- .billing.state
    '{billing_postcode}', -- .billing.postcode
    '{billing_country}', -- .billing.country
    '{billing_email}', -- .billing.email
    '{billing_phone}', -- .billing.phone
    '{shipping_first_name}', -- .shipping.first_name
    '{shipping_last_name}', -- .shipping.last_name
    '{shipping_company}', -- .shipping.company
    '{shipping_address_1}', -- .shipping.address_1
    '{shipping_address_2}', -- .shipping.address_2
    '{shipping_city}', -- .shipping.city
    '{shipping_state}', -- .shipping.state
    '{shipping_postcode}', -- .shipping.postcode
    '{shipping_country}', -- .shipping.country
    '{shipping_phone}', -- .shipping.phone, null x GAGLIARDETTI
    '{shipping_method_title}', --.shipping_lines[0].method_title, .shipping_methods x GAGLIARDETTI
    '{fee_name}', -- null, .fee_lines[0].name x PROMOSER
    '{fee_tax_class}', -- null, .fee_lines[0].tax_class x PROMOSER
    '{fee_total}', -- null, .fee_lines[0].total x PROMOSER
    '{fee_total_tax}', -- null, .fee_lines[0].total_tax x PROMOSER
    '{coupon_code}', -- null, .coupon_lines[0].code x PROMOSER
    '{coupon_discount}', -- null, .coupon_lines[0].discount x PROMOSER
    '{coupon_discount_tax}', -- null, .coupon_lines[0].discount_tax x PROMOSER
    '{coupon_discount_type}', -- null, .coupon_lines[0].discount_type x PROMOSER
    {coupon_nominal_amount}, -- null, .coupon_lines[0].nominal_amount x PROMOSER
    {coupon_free_shipping}, -- null, .coupon_lines[0].free_shipping x PROMOSER
    '{created_via}', -- .created_via, null x GAGLIARDETTI
    {is_editable}, -- .is_editable, null x GAGLIARDETTI
    '{date_created}', -- .date_created, .created_at x GAGLIARDETTI
    '{date_created_gmt}', -- .date_created_gmt, null x GAGLIARDETTI
    '{date_modified}', -- .date_modified, .updated_at x GAGLIARDETTI
    '{date_modified_gmt}', -- .date_modified_gmt, null x GAGLIARDETTI
    '{date_completed}', -- .date_completed, .completed_at x GAGLIARDETTI
    '{date_completed_gmt}', -- .date_completed_gmt, null x GAGLIARDETTI
    '{date_paid}', -- .date_paid
    '{date_paid_gmt}', -- .date_paid_gmt, null x GAGLIARDETTI
    null,
    null
)


INSERT dbo.[CliOrdLinImp_Pers](origin, id, id_lin, product_id, parent_name, variation_id, name, sku, price, quantity, subtotal, total, tax_class, subtotal_tax, total_tax, link_image, UniqDoc, Uniq, PrdCod)
VALUES(
    '{origin}', -- si aspetta 'promoser', 'gagliardetti' o 'adunata' in base a quale invia i dati
    {id}, -- .id
    {id_lin}, -- .line_items[X].id
    {product_id}, -- .line_items[X].product_id
    '{parent_name}', -- .line_items[X].parent_name,  .line_items[X].name x GAGLIARDETTI
    {variation_id}, -- .line_items[X].variation_id, null x GAGLIARDETTI
    '{name}', -- .line_items[X].name, null x GAGLIARDETTI
    '{sku}', -- .line_items[X].sku
    '{price}', -- .line_items[X].price
    {quantity}, -- .line_items[X].quantity
    '{subtotal}', -- .line_items[X].subtotal
    '{total}', -- .line_items[X].total
    '{tax_class}', -- .line_items[X].tax_class
    '{subtotal_tax}', -- .line_items[X].subtotal_tax
    '{total_tax}', -- .line_items[X].total_tax
    '{link_image}', -- .line_items[X].image.src, null x GAGLIARDETTI
    null,
    null,
    null
)


INSERT dbo.[CliOrdLinParImp_Pers](origin, id, id_lin, id_par, key_, display_key, value, display_value, UniqDoc, UniqLin, ParID)
VALUES(
    '{origin}', -- si aspetta 'promoser', 'gagliardetti' o 'adunata' in base a quale invia i dati
    {id}, -- .id
    {id_lin}, -- .line_items[X].id
    {id_par}, -- .line_items[X].meta_data[X].id
    '{key_}', -- .line_items[X].meta_data[X].key
    '{display_key}', -- .line_items[X].meta_data[X].display_key
    '{value}', -- .line_items[X].meta_data[X].value
    '{display_value}', -- .line_items[X].meta_data[X].display_value
    null,
    null,
    null
)