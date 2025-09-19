INSERT dbo.[CliOrdImp_Pers](origin, id, number, order_key, cart_hash, parent_id, status, version, link_self, customer_id, customer_email, customer_first_name, customer_last_name, customer_role, customer_note, customer_ip_address, customer_user_agent, link_customer, needs_payment, needs_processing, payment_method, payment_method_title, currency, transaction_id, payment_url, total, subtotal, discount_total, shipping_total, total_tax, cart_tax, discount_tax, shipping_tax, prices_include_tax, tax_id, tax_rate_code, tax_rate_id, tax_label, tax_compound, tax_tax_total, tax_rate_percent, total_line_items_quantity, billing_first_name, billing_last_name, billing_company, billing_address_1, billing_address_2, billing_city, billing_state, billing_postcode, billing_country, billing_email, billing_phone, shipping_first_name, shipping_last_name, shipping_company, shipping_address_1, shipping_address_2, shipping_city, shipping_state, shipping_postcode, shipping_country, shipping_phone, shipping_method_title, fee_name, fee_tax_class, fee_total, fee_total_tax, coupon_code, coupon_discount, coupon_discount_tax, coupon_discount_type, coupon_nominal_amount, coupon_free_shipping, created_via, is_editable, date_created, date_created_gmt, date_modified, date_modified_gmt, date_completed, date_completed_gmt, date_paid, date_paid_gmt, Uniq, AnaCod)
VALUES(
    'promoser', -- origin
    24759,  -- id
    '24759',    -- number
    'wc_order_tAdGI3BY67qpN',   -- order_key
    '990b122d110fca9cd81f886afd16bcfb', -- cart_hash
    0,  -- parent_id
    'completed',    -- status
    '9.7.1',    -- version
    'https://www.promoser.net/wp-json/wc/v3/orders/24759',  -- link_self
    420,    -- customer_id
    null,   -- customer_email
    null,   -- customer_first_name
    null,   -- customer_last_name
    null,   -- customer_role
    'per qualsiasi cosa mi potete chiamare 3483053278 MASSIMO MARASCO', -- customer_note
    '93.147.142.120',   -- customer_ip_address
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',  -- customer_user_agent
    'https://www.promoser.net/wp-json/wc/v3/customers/420', -- link_customer
    0,  -- needs_payment
    1,  -- needs_processing
    'bacs', -- payment_method
    'Bonifico Bancario anticipato', -- payment_method_title
    'EUR',  -- currency
    null,   -- transaction_id
    'https://www.promoser.net/pagamento/order-pay/24759/?pay_for_order=true&key=wc_order_tAdGI3BY67qpN',    -- payment_url
    '165.25',   -- total
    null,   -- subtotal
    '19.35',    -- discount_total
    '0.00', -- shipping_total
    '29.80',    -- total_tax
    '29.80',    -- cart_tax
    '4.26', -- discount_tax
    '0.00', -- shipping_tax
    0,  -- prices_include_tax
    724,    -- tax_id
    'IT-IVA-1', -- tax_rate_code
    1,  -- tax_rate_id
    'IVA',  -- tax_label
    0,  -- tax_compound
    '29.80',    -- tax_tax_total
    22, -- tax_rate_percent
    null,   -- total_line_items_quantity
    'Massimo',  -- billing_first_name
    'MARASCO',  -- billing_last_name
    'promo gift di marasco massimo',    -- billing_company
    'VIA A. VICI 8',    -- billing_address_1
    null,   -- billing_address_2
    'FOLIGNO',  -- billing_city
    'PG',   -- billing_state
    '06034',    -- billing_postcode
    'IT',   -- billing_country
    'massimomarasco@promogiftsnc.it',   -- billing_email
    '3483053278',   -- billing_phone
    'Massimo',  -- shipping_first_name
    'MARASCO',  -- shipping_last_name
    'promo gift di marasco massimo',    -- shipping_company
    'VIA A. VICI 8',    -- shipping_address_1
    null,   -- shipping_address_2
    'FOLIGNO',  -- shipping_city
    'PG',   -- shipping_state
    '06034',    -- shipping_postcode
    'IT',   -- shipping_country
    null,   -- shipping_phone
    'Porto Assegnato - INDICARE NELLE NOTE I DATI DEL VS. CORRIERE (Nome e Cod. Cliente)',  -- shipping_method_title
    'Spedizione rapida',    -- fee_name
    null,   -- fee_tax_class
    '25.80',    -- fee_total
    '5.68', -- fee_total_tax
    'b15',  -- coupon_code
    '19.35',    -- coupon_discount
    '4.26', -- coupon_discount_tax
    'percent',  -- coupon_discount_type
    15, -- coupon_nominal_amount
    0,  -- coupon_free_shipping
    'checkout', -- created_via
    0,  -- is_editable
    '2025-03-04T11:36:57',  -- date_created
    '2025-03-04T10:36:57',  -- date_created_gmt
    '2025-03-18T15:23:27',  -- date_modified
    '2025-03-18T14:23:27',  -- date_modified_gmt
    '2025-03-18T15:23:27',  -- date_completed
    '2025-03-18T14:23:27',  -- date_completed_gmt
    '2025-03-18T15:23:27',  -- date_paid
    '2025-03-18T14:23:27',  -- date_paid_gmt
    null,   -- Uniq
    null    -- AnaCod
)


--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
----##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--
--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
----##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--
--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

INSERT dbo.[CliOrdLinImp_Pers](origin, id, id_lin, product_id, parent_name, variation_id, name, sku, price, quantity, subtotal, total, tax_class, subtotal_tax, total_tax, link_image, UniqDoc, Uniq, PrdCod)
VALUES(
    'promoser', -- origin
    24759, -- id
    720, -- id_lin
    18263, -- product_id
    'Gagliardetto triangolare Modello 1F (26,5x34,5 cm)',    -- parent_name
    18283,   -- variation_id
    'Gagliardetto triangolare Modello 1F (26,5x34,5 cm)',   -- name
    'GAGLIARDETTO-TRIANGOLARE-1F',    -- sku
    '3.6550000000000002',  -- price
    30,   -- quantity
    '129.00',   -- subtotal
    '109.65',  -- total
    null,  -- tax_class
    '28.38',   -- subtotal_tax
    '24.12',  -- total_tax
    'https://www.promoser.net/wp-content/uploads/2023/12/gagliardetto-triangolare-personalizzato-fronte-modelli-1F.webp', -- link_image
    null,    -- UniqDoc
    null,   -- Uniq
    null  -- PrdCod
),(
    'promoser', -- origin
    24759, -- id
    721, -- id_lin
    21479, -- product_id
    null,    -- parent_name
    0,   -- variation_id
    'Spedizione Rapida (Solo per Gagliardetti)',   -- name
    null,    -- sku
    '0',  -- price
    1,   -- quantity
    '0.00',   -- subtotal
    '0.00',  -- total
    null,  -- tax_class
    '0.00',   -- subtotal_tax
    '0.00',  -- total_tax
    'https://www.promoser.net/wp-content/uploads/2024/01/gagliardetti-spedizione-veloce.webp', -- link_image
    null,    -- UniqDoc
    null,   -- Uniq
    null  -- PrdCod
)

--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
----##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--
--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
----##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--
--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

INSERT dbo.[CliOrdLinParImp_Pers](origin, id, id_lin, id_par, key_, display_key, value, display_value, UniqDoc, UniqLin, ParID)
VALUES(
    'promoser', -- origin
    24759, -- id
    720, -- id_lin
    6615, -- id_par
    'pa_personalizzazione',   -- key_
    'Personalizzazione',    -- display_key
    'neutro-gagliardetti-stendardi-gonfaloni',  -- value
    'Neutro',  -- display_value
    null,    -- UniqDoc
    null,    -- UniqLin
    null   -- ParID
),(
    'promoser', -- origin
    24759, -- id
    720, -- id_lin
    6616, -- id_par
    'pa_supporto-gagliardetti',   -- key_
    'Supporto',    -- display_key
    'raso-strong',  -- value
    'Raso Strong',  -- display_value
    null,    -- UniqDoc
    null,    -- UniqLin
    null   -- ParID
),(
    'promoser', -- origin
    24759, -- id
    720, -- id_lin
    6617, -- id_par
    'pa_retro-gagliardetti-stendardi',   -- key_
    'Retro',    -- display_key
    'retro-gagliardetti-stendardi-gonfaloni-bianco',  -- value
    'Retro Bianco',  -- display_value
    null,    -- UniqDoc
    null,    -- UniqLin
    null   -- ParID
),(
    'promoser', -- origin
    24759, -- id
    720, -- id_lin
    6618, -- id_par
    'pa_borchie-gagliardetti-9-mm',   -- key_
    'Borchie ⌀ 9 mm',    -- display_key
    'borchie-ottone-dorato-gagliardetti',  -- value
    'Borchie ottone dorato',  -- display_value
    null,    -- UniqDoc
    null,    -- UniqLin
    null   -- ParID
),(
    'promoser', -- origin
    24759, -- id
    720, -- id_lin
    6619, -- id_par
    'pa_colore-cordino-gagliardetti',   -- key_
    'Colore Cordino',    -- display_key
    'cordino-gagliardetti-oro',  -- value
    'Oro (COME DA FOTO)',  -- display_value
    null,    -- UniqDoc
    null,    -- UniqLin
    null   -- ParID
),(
    'promoser', -- origin
    24759, -- id
    720, -- id_lin
    6620, -- id_par
    'pa_colore-rifinitura-guidoncini',   -- key_
    'Colore rifinitura',    -- display_key
    'cordino-frangia-oro',  -- value
    'Oro (COME DA FOTO)',  -- display_value
    null,    -- UniqDoc
    null,    -- UniqLin
    null   -- ParID
),(
    'promoser', -- origin
    24759, -- id
    720, -- id_lin
    6621, -- id_par
    'pa_variante-gagliardetti',   -- key_
    'Variante rifinitura*',    -- display_key
    'frangia-cordonetto-gagliardetti-b',  -- value
    'B (frangia cordonetto da 3 cm)',  -- display_value
    null,    -- UniqDoc
    null,    -- UniqLin
    null   -- ParID
)