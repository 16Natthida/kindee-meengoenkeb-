-- ============================================================
-- Seed: meal_templates + meal_template_ingredients (40+ เมนู)
-- ============================================================

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('e045e0a4-8ab6-594f-a3df-3c50a467c414', 'ข้าวไข่เจียว', 'อาหารเช้า', 25, 10, 'easy', ARRAY['เตาแก๊ส']::text[], 'ตีไข่กับน้ำปลา ทอดในกระทะน้ำมันร้อนจนสุกเหลือง เสิร์ฟกับข้าวสวย', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('49da5368-cc03-58a6-983e-d65b2e25e1f0', 'e045e0a4-8ab6-594f-a3df-3c50a467c414', 'ไข่ไก่', 2, 'ฟอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('61d73062-477c-51a5-8ae0-1477d2fcd233', 'e045e0a4-8ab6-594f-a3df-3c50a467c414', 'ข้าวสวย', 1, 'จาน');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('33cee9b5-05de-5221-949b-65b5fdd3e5a9', 'e045e0a4-8ab6-594f-a3df-3c50a467c414', 'น้ำปลา', 1, 'tsp');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('5d8f0484-6a56-5aa7-84e3-016c3af7886c', 'e045e0a4-8ab6-594f-a3df-3c50a467c414', 'น้ำมันพืช', 2, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('a8d454cc-0f45-57a3-8651-93b68d94dc00', 'ข้าวต้มหมูสับ', 'อาหารเช้า', 30, 15, 'easy', ARRAY['เตาแก๊ส']::text[], 'ต้มข้าวสวยกับน้ำซุป ใส่หมูสับปั้นก้อน ปรุงรสด้วยซีอิ๊วขาว โรยต้นหอม', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('d34894b1-14b4-577f-b804-1f2dd131dbe9', 'a8d454cc-0f45-57a3-8651-93b68d94dc00', 'ข้าวสวย', 1, 'จาน');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('bdea1bdf-fe91-5744-a430-8b458c7db4d0', 'a8d454cc-0f45-57a3-8651-93b68d94dc00', 'หมูสับ', 100, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('b9f478b3-4f0a-5d85-953d-7a6231f65ddb', 'a8d454cc-0f45-57a3-8651-93b68d94dc00', 'ซีอิ๊วขาว', 1, 'tbsp');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('019e89f1-45aa-5cb2-b0a1-6ad0989d8582', 'a8d454cc-0f45-57a3-8651-93b68d94dc00', 'ต้นหอม', 1, 'ต้น');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('7cbd171f-1ad9-5706-9eb4-fe579ca9d877', 'แซนวิชแฮมชีส', 'อาหารเช้า', 35, 8, 'easy', '{}'::text[], 'ทาเนยบนขนมปัง วางแฮมและชีส ปิ้งจนเหลืองกรอบ', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('69708390-f946-5289-9dd2-0af52aa61e11', '7cbd171f-1ad9-5706-9eb4-fe579ca9d877', 'ขนมปังแผ่น', 2, 'แผ่น');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('7079e62c-ab85-5d3e-b2a0-f34627cc2d47', '7cbd171f-1ad9-5706-9eb4-fe579ca9d877', 'แฮม', 2, 'แผ่น');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('59cb6fb3-9eed-58a5-bf10-6c672ddbfd58', '7cbd171f-1ad9-5706-9eb4-fe579ca9d877', 'ชีสแผ่น', 1, 'แผ่น');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('257c2e58-be32-5026-9735-eeacb7159e90', '7cbd171f-1ad9-5706-9eb4-fe579ca9d877', 'เนย', 1, 'tsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('6b6bdb6b-0cb7-582c-8ad6-f42d6815eb82', 'โจ๊กหมู', 'อาหารเช้า', 25, 20, 'easy', ARRAY['หม้อหุงข้าว']::text[], 'ต้มข้าวกับน้ำจนเปื่อย ใส่หมูสับ ปรุงรส โรยขิงซอยและต้นหอม', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('de674e82-9d83-5f9a-92e4-dc1d65afc1fe', '6b6bdb6b-0cb7-582c-8ad6-f42d6815eb82', 'ข้าวสาร', 0.5, 'cup');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('ca507feb-7cc2-5bb7-89fa-88f2ea5f4284', '6b6bdb6b-0cb7-582c-8ad6-f42d6815eb82', 'หมูสับ', 100, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('403b434c-5489-53bf-a919-c1ade75145f6', '6b6bdb6b-0cb7-582c-8ad6-f42d6815eb82', 'ขิง', 10, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('62edec59-b2aa-5f23-b7d5-1b73725c1b47', '6b6bdb6b-0cb7-582c-8ad6-f42d6815eb82', 'ต้นหอม', 1, 'ต้น');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('0c50df29-0f7d-5c5b-a885-8ab289b7f63c', 'นมโอ๊ตกล้วยปั่น', 'อาหารเช้า', 20, 5, 'easy', ARRAY['เครื่องปั่น']::text[], 'ปั่นกล้วย นม และโอ๊ตเข้าด้วยกันจนเนียน', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('02f82ace-93f9-5fb0-b01b-98cc70fafe1a', '0c50df29-0f7d-5c5b-a885-8ab289b7f63c', 'กล้วยน้ำว้า', 1, 'ลูก');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('3242616c-a082-5da7-a25c-4663eb3c79ec', '0c50df29-0f7d-5c5b-a885-8ab289b7f63c', 'นมจืด', 200, 'ml');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('4ca7f485-e9bf-531d-9083-d7647fc6cb7c', '0c50df29-0f7d-5c5b-a885-8ab289b7f63c', 'โอ๊ต', 2, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('f5fe3dd1-7df9-59fb-a99e-9b82076fabdb', 'ข้าวผัดกะเพราหมู', 'อาหารจานเดียว', 35, 15, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดกระเทียมพริกกับหมูสับให้สุก ใส่ใบกะเพรา ปรุงรส ตักราดข้าวสวย', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('fbbf2d66-6d36-56ff-9ba1-6bed4bf6af0c', 'f5fe3dd1-7df9-59fb-a99e-9b82076fabdb', 'หมูสับ', 120, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('70163858-4e1a-5ad4-991e-de5b3ada4ff2', 'f5fe3dd1-7df9-59fb-a99e-9b82076fabdb', 'ใบกะเพรา', 1, 'กำ');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('0e3d0859-c40e-5a6c-8474-05cc721d1217', 'f5fe3dd1-7df9-59fb-a99e-9b82076fabdb', 'กระเทียม', 5, 'กลีบ');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('ed2e0e8c-72e3-533d-a866-bb2f465d58cf', 'f5fe3dd1-7df9-59fb-a99e-9b82076fabdb', 'พริกขี้หนู', 5, 'เม็ด');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('c7f1fa44-e48c-5bb9-bb03-292eefddd029', 'f5fe3dd1-7df9-59fb-a99e-9b82076fabdb', 'ข้าวสวย', 1, 'จาน');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('e938c72e-b0ab-5c88-afaf-b1cf6fc5c333', 'ข้าวผัดไข่', 'อาหารจานเดียว', 25, 10, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดข้าวสวยกับไข่และซีอิ๊ว ปรุงรสตามชอบ', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('32525303-457e-519f-a6ce-dca27a9eb3c4', 'e938c72e-b0ab-5c88-afaf-b1cf6fc5c333', 'ข้าวสวย', 1, 'จาน');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('764953c2-2192-5b67-95ec-e18947d5ee1a', 'e938c72e-b0ab-5c88-afaf-b1cf6fc5c333', 'ไข่ไก่', 1, 'ฟอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('0034bd71-74ec-591a-9c1a-14526ebb927c', 'e938c72e-b0ab-5c88-afaf-b1cf6fc5c333', 'ซีอิ๊วขาว', 1, 'tbsp');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('0c4526b5-6128-5736-9ba4-3a9d7df2f6e4', 'e938c72e-b0ab-5c88-afaf-b1cf6fc5c333', 'ต้นหอม', 1, 'ต้น');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('dca4cb36-b39d-5541-be59-9983b22ef82f', 'ผัดซีอิ๊วหมู', 'อาหารจานเดียว', 35, 15, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดเส้นใหญ่กับหมูและคะน้าในซีอิ๊วดำจนหอม', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('37ee9766-e89c-5a8a-bb7b-fb506232df8d', 'dca4cb36-b39d-5541-be59-9983b22ef82f', 'เส้นใหญ่', 150, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('4033348c-4c24-588a-92f3-20934c7e1f7b', 'dca4cb36-b39d-5541-be59-9983b22ef82f', 'หมูสับ', 100, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('99cd8ec6-0894-5c29-b300-08083b43b44e', 'dca4cb36-b39d-5541-be59-9983b22ef82f', 'คะน้า', 50, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('48aeaf34-e075-56bd-9f13-5e45db744fe1', 'dca4cb36-b39d-5541-be59-9983b22ef82f', 'ซีอิ๊วดำ', 2, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('e648b5d9-55e0-5c78-8286-07ecf2b2707f', 'ข้าวหมูทอดกระเทียม', 'อาหารจานเดียว', 40, 20, 'medium', ARRAY['เตาแก๊ส']::text[], 'หมักหมูกับกระเทียมและพริกไทย ทอดจนสุกเหลือง เสิร์ฟกับข้าวสวย', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('4184c8e9-5941-53cd-b3e3-4edb57e8e471', 'e648b5d9-55e0-5c78-8286-07ecf2b2707f', 'หมูสไลซ์', 120, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('403af432-0dbb-5971-a0e2-d7c28c40313f', 'e648b5d9-55e0-5c78-8286-07ecf2b2707f', 'กระเทียม', 5, 'กลีบ');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('edd54a92-5fad-5e6c-8fe5-35baacb6b714', 'e648b5d9-55e0-5c78-8286-07ecf2b2707f', 'พริกไทย', 0.5, 'tsp');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('88534779-c125-5ed9-ab0f-a324f4e77a98', 'e648b5d9-55e0-5c78-8286-07ecf2b2707f', 'ข้าวสวย', 1, 'จาน');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('342d534a-dbaa-5448-96d6-135f4941e21e', 'ราดหน้าหมู', 'อาหารจานเดียว', 40, 20, 'medium', ARRAY['เตาแก๊ส']::text[], 'ผัดหมูกับผัก ราดด้วยน้ำซอสข้นบนเส้นใหญ่ทอด', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('68468b03-37c1-504d-a731-7d2845cd9dd8', '342d534a-dbaa-5448-96d6-135f4941e21e', 'เส้นใหญ่', 150, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('e9b36dc5-a23e-5221-9326-eb4e1458dc2e', '342d534a-dbaa-5448-96d6-135f4941e21e', 'หมูสไลซ์', 100, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('572c1c9d-8b51-518c-b8fe-030b29b7d1b7', '342d534a-dbaa-5448-96d6-135f4941e21e', 'คะน้า', 50, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('bc8c705f-aee8-5037-9548-38cbefc9d638', '342d534a-dbaa-5448-96d6-135f4941e21e', 'แป้งมัน', 1, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('955d56ee-a870-5069-98b3-6819b11657f1', 'ต้มยำไก่', 'กับข้าว', 40, 20, 'medium', ARRAY['เตาแก๊ส']::text[], 'ต้มน้ำซุปกับสมุนไพร ใส่ไก่ ปรุงรสเปรี้ยวเผ็ด', 2, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('f6610d08-6b83-5c5c-8c5b-b98081e6c33f', '955d56ee-a870-5069-98b3-6819b11657f1', 'ไก่', 200, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('2dc62d61-35f1-5394-9532-ac1b6ace5445', '955d56ee-a870-5069-98b3-6819b11657f1', 'ตะไคร้', 2, 'ต้น');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('20ec2867-c0a6-5248-b5d1-d171d5c8633c', '955d56ee-a870-5069-98b3-6819b11657f1', 'ใบมะกรูด', 4, 'ใบ');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('7b9c63ab-2cd5-5c71-8790-703b4606a29d', '955d56ee-a870-5069-98b3-6819b11657f1', 'น้ำมะนาว', 2, 'tbsp');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('4af1a2c8-94b7-5f79-b14b-8f8cbb74a3f3', '955d56ee-a870-5069-98b3-6819b11657f1', 'พริกป่น', 1, 'tsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('5d09221a-4371-5202-ac00-866269f16e4f', 'แกงจืดเต้าหู้หมูสับ', 'กับข้าว', 30, 15, 'easy', ARRAY['เตาแก๊ส']::text[], 'ต้มน้ำซุป ใส่หมูสับปั้นก้อนและเต้าหู้ ปรุงรสอ่อน ๆ', 2, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('de336815-ee79-5e36-acb3-7f20771c1717', '5d09221a-4371-5202-ac00-866269f16e4f', 'หมูสับ', 100, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('5f6cebbd-720d-5bd8-928e-25bd7daa8fe8', '5d09221a-4371-5202-ac00-866269f16e4f', 'เต้าหู้ขาว', 1, 'ก้อน');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('a324bde4-ca45-5752-a444-e4112f7086db', '5d09221a-4371-5202-ac00-866269f16e4f', 'ผักกาดขาว', 50, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('b9638ce0-7640-5837-b930-2e9e89ad48cb', '5d09221a-4371-5202-ac00-866269f16e4f', 'ซีอิ๊วขาว', 1, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('a49e78cd-57cf-5360-9af5-72c4f93cceeb', 'ผัดผักบุ้งไฟแดง', 'กับข้าว', 25, 10, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดผักบุ้งกับกระเทียมและพริกด้วยไฟแรง ปรุงรสเค็มหวาน', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('8f21d65a-167b-52db-ac83-c0289cbdbcc9', 'a49e78cd-57cf-5360-9af5-72c4f93cceeb', 'ผักบุ้ง', 1, 'กำ');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('1b52ed77-9bb1-5c80-af1a-3e1028b1d366', 'a49e78cd-57cf-5360-9af5-72c4f93cceeb', 'กระเทียม', 5, 'กลีบ');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('f88b79cd-4245-527c-8fc9-d4dedb81d9c2', 'a49e78cd-57cf-5360-9af5-72c4f93cceeb', 'เต้าเจี้ยว', 1, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('1952d2d6-cac6-5f76-b5b4-46339aec1722', 'ไข่พะโล้', 'กับข้าว', 35, 40, 'medium', ARRAY['เตาแก๊ส']::text[], 'ต้มไข่ต้มกับหมูสามชั้นในน้ำพะโล้จนเข้าเนื้อ', 3, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('a299421c-769d-5da4-81b4-694e595cf249', '1952d2d6-cac6-5f76-b5b4-46339aec1722', 'ไข่ไก่', 4, 'ฟอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('89f4f5d0-3251-5491-bdd4-364435c01168', '1952d2d6-cac6-5f76-b5b4-46339aec1722', 'หมูสามชั้น', 200, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('2274bfc6-73fb-5c92-bf9d-9868e355738d', '1952d2d6-cac6-5f76-b5b4-46339aec1722', 'ซีอิ๊วดำ', 2, 'tbsp');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('41be9628-de67-5533-8fa6-3ddbb4fa7220', '1952d2d6-cac6-5f76-b5b4-46339aec1722', 'อบเชย', 1, 'ชิ้น');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('092b68cd-a509-55fa-8cd8-85d8bff12883', 'แกงเขียวหวานไก่', 'กับข้าว', 45, 25, 'medium', ARRAY['เตาแก๊ส']::text[], 'ผัดพริกแกงกับกะทิ ใส่ไก่และมะเขือ ต้มจนสุก', 2, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('f7f0dc02-644e-5def-aedc-7c5e0ba482de', '092b68cd-a509-55fa-8cd8-85d8bff12883', 'ไก่', 200, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('1aba40d2-1a59-5829-9601-9804a0b9ba0e', '092b68cd-a509-55fa-8cd8-85d8bff12883', 'พริกแกงเขียวหวาน', 2, 'tbsp');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('4f3ca248-a914-5e7d-9be9-bb4e037b9c49', '092b68cd-a509-55fa-8cd8-85d8bff12883', 'กะทิ', 200, 'ml');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('c89c3a84-4013-59e6-ae8d-87ebd888ee98', '092b68cd-a509-55fa-8cd8-85d8bff12883', 'มะเขือเปราะ', 5, 'ลูก');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('f725966d-c2f6-5095-a5bb-bd706cc195de', 'คะน้าหมูกรอบ', 'กับข้าว', 40, 15, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดคะน้ากับหมูกรอบและกระเทียมในซอสหอยนางรม', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('5a5066c9-43a6-5e3b-92da-4e036c16d7fc', 'f725966d-c2f6-5095-a5bb-bd706cc195de', 'คะน้า', 1, 'กำ');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('ee1f2746-9402-59b6-b257-8a61d4587ccc', 'f725966d-c2f6-5095-a5bb-bd706cc195de', 'หมูกรอบ', 100, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('49a53ad7-1faa-59ce-8562-74d3a7e5ec92', 'f725966d-c2f6-5095-a5bb-bd706cc195de', 'ซอสหอยนางรม', 1, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('5f405ac1-3139-53c3-8d7e-faaffa7573e6', 'ผัดฟักทองไข่', 'กับข้าว', 25, 15, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดฟักทองหั่นชิ้นกับไข่และกระเทียมจนสุกนุ่ม', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('db07f3df-ee8e-5553-a60e-431fe19ce832', '5f405ac1-3139-53c3-8d7e-faaffa7573e6', 'ฟักทอง', 150, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('7d6c865a-3da5-5999-9066-e1b276164489', '5f405ac1-3139-53c3-8d7e-faaffa7573e6', 'ไข่ไก่', 1, 'ฟอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('e82314ea-f3e9-5906-a4ad-640d15dc430c', '5f405ac1-3139-53c3-8d7e-faaffa7573e6', 'กระเทียม', 3, 'กลีบ');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('0a76a5f3-721a-59fa-9a19-d9ac6947ff73', 'ไข่ต้ม', 'เมนูประหยัด', 8, 10, 'easy', ARRAY['หม้อ']::text[], 'ต้มไข่ในน้ำเดือดประมาณ 8-10 นาทีจนสุก', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('f72b4c3f-e09d-51c9-9de7-9350cf92b2fd', '0a76a5f3-721a-59fa-9a19-d9ac6947ff73', 'ไข่ไก่', 2, 'ฟอง');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('01d0eada-4e0c-5254-ad30-53d3c8332bef', 'ผัดผักรวมมิตร', 'เมนูประหยัด', 20, 10, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดผักตามฤดูกาลรวมกันกับกระเทียมและน้ำมันหอย', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('1b8b9e9a-3f3c-55ea-90f1-524b9ab1a90a', '01d0eada-4e0c-5254-ad30-53d3c8332bef', 'ผักรวม', 200, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('f15d7b7b-5c6a-5c48-8cfb-7d00ee3b4b2d', '01d0eada-4e0c-5254-ad30-53d3c8332bef', 'กระเทียม', 3, 'กลีบ');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('6074517e-9a03-564b-8ad1-8e6a9a5b170d', '01d0eada-4e0c-5254-ad30-53d3c8332bef', 'ซอสหอยนางรม', 1, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('6dd7b254-132a-5af0-ab05-8f28c7444555', 'ข้าวคลุกน้ำปลาไข่ดาว', 'เมนูประหยัด', 18, 8, 'easy', ARRAY['เตาแก๊ส']::text[], 'ทอดไข่ดาว คลุกข้าวสวยกับน้ำปลาและพริกป่น', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('1d794da2-196d-5f54-8847-b285776aad7d', '6dd7b254-132a-5af0-ab05-8f28c7444555', 'ข้าวสวย', 1, 'จาน');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('e929f1f1-19a0-5f31-8d10-b5c1933c07ce', '6dd7b254-132a-5af0-ab05-8f28c7444555', 'ไข่ไก่', 1, 'ฟอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('198077cb-65ce-5528-87b8-08c64c3b4a93', '6dd7b254-132a-5af0-ab05-8f28c7444555', 'น้ำปลา', 1, 'tsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('ad17e9f3-a17d-5175-8c9f-b5d9d9acbfd0', 'มาม่าต้มไข่', 'เมนูประหยัด', 15, 7, 'easy', ARRAY['เตาแก๊ส']::text[], 'ต้มบะหมี่กึ่งสำเร็จรูปกับไข่ตามสูตรบนซอง', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('8ba6545c-0a5f-5ead-8365-3f31cdcfb25d', 'ad17e9f3-a17d-5175-8c9f-b5d9d9acbfd0', 'บะหมี่กึ่งสำเร็จรูป', 1, 'ซอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('e3964577-ce86-5fe7-bed6-d76022eca16c', 'ad17e9f3-a17d-5175-8c9f-b5d9d9acbfd0', 'ไข่ไก่', 1, 'ฟอง');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('e3b4e306-a134-5fde-96a6-e0682d7390fe', 'ข้าวเปล่าราดซีอิ๊ว', 'เมนูประหยัด', 10, 3, 'easy', '{}'::text[], 'ราดซีอิ๊วขาวและน้ำมันงาบนข้าวสวยร้อน ๆ', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('65104851-be02-5a8d-a9da-9ab8acfb9fe3', 'e3b4e306-a134-5fde-96a6-e0682d7390fe', 'ข้าวสวย', 1, 'จาน');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('690f628d-52b3-5576-8167-2d2e9fc8594a', 'e3b4e306-a134-5fde-96a6-e0682d7390fe', 'ซีอิ๊วขาว', 1, 'tbsp');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('4bc06d24-3ac7-510c-a0f1-a78041e2f3f1', 'e3b4e306-a134-5fde-96a6-e0682d7390fe', 'น้ำมันงา', 1, 'tsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('42032ab6-ba0d-57b5-ac18-6ce9f3f14258', 'ไข่เจียวไมโครเวฟ', 'เมนูใช้เวลาไม่เกิน 15 นาที', 20, 5, 'easy', ARRAY['ไมโครเวฟ']::text[], 'ตีไข่กับเครื่องปรุง เข้าไมโครเวฟ 90 วินาที', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('276484a2-5389-5c7b-a109-bfa597780d57', '42032ab6-ba0d-57b5-ac18-6ce9f3f14258', 'ไข่ไก่', 2, 'ฟอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('7c0b09a7-4d7e-5b66-bf1a-3e5d2ebdf07d', '42032ab6-ba0d-57b5-ac18-6ce9f3f14258', 'น้ำปลา', 1, 'tsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('ac0305f5-83d6-5c6f-8b30-8c8e65a273c3', 'ข้าวไก่ทอดพร้อมทาน', 'เมนูใช้เวลาไม่เกิน 15 นาที', 35, 10, 'easy', ARRAY['ไมโครเวฟ']::text[], 'อุ่นไก่ทอดในไมโครเวฟ เสิร์ฟกับข้าวสวย', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('333175bb-40bd-5040-9adb-50ef58b3500c', 'ac0305f5-83d6-5c6f-8b30-8c8e65a273c3', 'ไก่ทอดพร้อมทาน', 150, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('f09a9ffa-8b7d-593b-a13c-047b778719a6', 'ac0305f5-83d6-5c6f-8b30-8c8e65a273c3', 'ข้าวสวย', 1, 'จาน');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('9add91b1-0f66-5b48-af5e-55f44f27169e', 'ผัดกะหล่ำไข่เร็ว', 'เมนูใช้เวลาไม่เกิน 15 นาที', 22, 12, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดกะหล่ำปลีกับไข่และกระเทียมไฟแรง', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('e4d02088-904a-5490-a795-c71dd798a294', '9add91b1-0f66-5b48-af5e-55f44f27169e', 'กะหล่ำปลี', 100, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('f5dd33f6-b04d-5720-9520-6931be5bcf34', '9add91b1-0f66-5b48-af5e-55f44f27169e', 'ไข่ไก่', 1, 'ฟอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('4919999a-bf32-565a-8698-40e1bca6df28', '9add91b1-0f66-5b48-af5e-55f44f27169e', 'กระเทียม', 3, 'กลีบ');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('35c81b6b-2d21-527d-8a10-55a7438ca16a', 'แซนวิชทูน่า', 'เมนูใช้เวลาไม่เกิน 15 นาที', 30, 8, 'easy', '{}'::text[], 'ผสมทูน่ากับมายองเนส ทาบนขนมปัง', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('5ab1b38e-4dfb-59a4-9d31-bc95e97e15c4', '35c81b6b-2d21-527d-8a10-55a7438ca16a', 'ทูน่ากระป๋อง', 1, 'กระป๋อง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('40c8e541-50aa-5e7a-9c3a-40107e1fd9c0', '35c81b6b-2d21-527d-8a10-55a7438ca16a', 'ขนมปังแผ่น', 2, 'แผ่น');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('7bf29fb0-3a1d-59ea-9e03-446114adb436', '35c81b6b-2d21-527d-8a10-55a7438ca16a', 'มายองเนส', 1, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('0b4d2c82-eede-50c0-8850-c46b8f755c75', 'ไข่ตุ๋น', 'เมนูจากไข่', 25, 20, 'easy', ARRAY['หม้อหุงข้าว']::text[], 'ตีไข่กับน้ำซุปและซีอิ๊ว นึ่งจนไข่สุกนุ่ม', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('d190037c-62bf-5be7-bc36-4d9977c0c681', '0b4d2c82-eede-50c0-8850-c46b8f755c75', 'ไข่ไก่', 2, 'ฟอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('eafaffed-0daa-5358-b9a1-6471cb564ce3', '0b4d2c82-eede-50c0-8850-c46b8f755c75', 'น้ำซุป', 150, 'ml');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('4f88d3fa-9261-56f5-bca4-6e3a42286f89', '0b4d2c82-eede-50c0-8850-c46b8f755c75', 'ซีอิ๊วขาว', 1, 'tsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('cce07203-acba-52fa-ac11-e0497846dc58', 'ไข่ยัดไส้', 'เมนูจากไข่', 30, 20, 'medium', ARRAY['เตาแก๊ส']::text[], 'ผัดหมูสับกับผัก ห่อด้วยไข่เจียวแผ่นบาง', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('e88adc3e-13ed-5d19-9039-91397618893b', 'cce07203-acba-52fa-ac11-e0497846dc58', 'ไข่ไก่', 2, 'ฟอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('c7a76cf5-7195-5da6-8a1b-39f8ebf1c94c', 'cce07203-acba-52fa-ac11-e0497846dc58', 'หมูสับ', 80, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('fc21faf8-3134-5155-9aaf-9869f96a727c', 'cce07203-acba-52fa-ac11-e0497846dc58', 'แครอท', 30, 'g');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('b9e36f93-693d-5347-accf-b5981f00f9d6', 'ไข่พะเยาว์', 'เมนูจากไข่', 25, 15, 'easy', ARRAY['เตาแก๊ส']::text[], 'ทอดไข่ดาวราดน้ำมันร้อนให้ขอบกรอบ', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('c365166f-9a37-5c0c-802c-dd2d9ae2455b', 'b9e36f93-693d-5347-accf-b5981f00f9d6', 'ไข่ไก่', 2, 'ฟอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('e33b82b9-a653-5785-bd25-7c6e32730860', 'b9e36f93-693d-5347-accf-b5981f00f9d6', 'น้ำมันพืช', 3, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('c0a2c83d-39f4-5b64-b294-21de3886356e', 'ไข่ลูกเขย', 'เมนูจากไข่', 35, 20, 'medium', ARRAY['เตาแก๊ส']::text[], 'ทอดไข่ต้มให้ผิวกรอบ ราดด้วยซอสมะขามเปรี้ยวหวาน', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('bc5dfccb-bc0f-5c97-8b1d-c0b142cfb1ce', 'c0a2c83d-39f4-5b64-b294-21de3886356e', 'ไข่ไก่', 3, 'ฟอง');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('e4d5336c-1898-5737-8414-9e9640d71754', 'c0a2c83d-39f4-5b64-b294-21de3886356e', 'น้ำมะขามเปียก', 2, 'tbsp');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('93e60d3b-89fb-5f84-9b52-fc4ec3027d6c', 'c0a2c83d-39f4-5b64-b294-21de3886356e', 'น้ำตาลปี๊บ', 1, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('482b41c4-6ebf-517f-a851-3ca3965bb162', 'ข้าวผัดไก่', 'เมนูจากไก่', 35, 15, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดข้าวสวยกับไก่หั่นชิ้นและไข่', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('3bd519e5-09f0-5941-9b42-609f63e8ed08', '482b41c4-6ebf-517f-a851-3ca3965bb162', 'ไก่', 100, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('d11d4bfe-e6e8-5a7e-afdd-d1ae21bac635', '482b41c4-6ebf-517f-a851-3ca3965bb162', 'ข้าวสวย', 1, 'จาน');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('93be29a5-46dc-549b-88f4-5fa1fd640cba', '482b41c4-6ebf-517f-a851-3ca3965bb162', 'ไข่ไก่', 1, 'ฟอง');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('46874af5-26ac-5d3b-8a0b-3f7e078f8028', 'ไก่ผัดขิง', 'เมนูจากไก่', 35, 20, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดไก่กับขิงซอยและเห็ดหอมในซอสปรุงรส', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('4a4bc18a-e9e4-596e-8e6d-6a7242091006', '46874af5-26ac-5d3b-8a0b-3f7e078f8028', 'ไก่', 150, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('b4ec7f29-c97a-5df7-b5a0-5f79d4a8f5eb', '46874af5-26ac-5d3b-8a0b-3f7e078f8028', 'ขิงอ่อน', 30, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('c92840f3-ee0a-55dd-ae60-ef4c4d9d029d', '46874af5-26ac-5d3b-8a0b-3f7e078f8028', 'เห็ดหอม', 3, 'ดอก');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('8c1166bd-b3db-5089-877e-9deb2a5fcb5a', 'ไก่ทอดกระเทียมพริกไทย', 'เมนูจากไก่', 40, 25, 'medium', ARRAY['เตาแก๊ส']::text[], 'หมักไก่กับกระเทียมพริกไทย ทอดให้เหลืองกรอบ', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('c53558d7-de42-5d79-8ab2-c24354c159d1', '8c1166bd-b3db-5089-877e-9deb2a5fcb5a', 'ไก่', 200, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('8bed7b6f-c180-5e82-854b-d802e7d0446d', '8c1166bd-b3db-5089-877e-9deb2a5fcb5a', 'กระเทียม', 6, 'กลีบ');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('3408ea25-2df4-5b9f-9f2d-89ac5dfa83a2', '8c1166bd-b3db-5089-877e-9deb2a5fcb5a', 'พริกไทยป่น', 1, 'tsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('b9e4407e-a6a1-569d-a3cc-a35eb5972e9e', 'ต้มข่าไก่', 'เมนูจากไก่', 45, 25, 'medium', ARRAY['เตาแก๊ส']::text[], 'ต้มกะทิกับข่า ตะไคร้ ใส่ไก่และเห็ด ปรุงรส', 2, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('59372e4f-7158-5223-9564-e9b6f01970b1', 'b9e4407e-a6a1-569d-a3cc-a35eb5972e9e', 'ไก่', 200, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('15bc3db7-e651-5e53-8a6c-27f13414865b', 'b9e4407e-a6a1-569d-a3cc-a35eb5972e9e', 'กะทิ', 250, 'ml');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('90368daf-0f5b-5bd5-b3d1-5abb42c382d7', 'b9e4407e-a6a1-569d-a3cc-a35eb5972e9e', 'ข่า', 20, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('8826ac92-29f9-5527-a1fb-5a7ec4cfd77e', 'b9e4407e-a6a1-569d-a3cc-a35eb5972e9e', 'เห็ดฟาง', 50, 'g');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('b807cc17-62bf-5c9f-9632-67d37d33ebf1', 'หมูผัดพริกแกง', 'เมนูจากหมู', 35, 20, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดพริกแกงกับหมูสไลซ์และถั่วฝักยาว', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('22851353-2bc1-590d-8439-d76808f13772', 'b807cc17-62bf-5c9f-9632-67d37d33ebf1', 'หมูสไลซ์', 120, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('a13f61b2-2c09-5eaa-aca6-687edd41834f', 'b807cc17-62bf-5c9f-9632-67d37d33ebf1', 'พริกแกงเผ็ด', 1, 'tbsp');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('cd257b64-7781-5d49-b834-e6e03b96793b', 'b807cc17-62bf-5c9f-9632-67d37d33ebf1', 'ถั่วฝักยาว', 50, 'g');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('3333be12-6bde-5692-b716-6079eb45b833', 'หมูสับผัดกระเทียม', 'เมนูจากหมู', 30, 15, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดหมูสับกับกระเทียมเจียวจนหอม ปรุงรส', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('5ea40aaa-3373-59b3-b746-35e714de6d06', '3333be12-6bde-5692-b716-6079eb45b833', 'หมูสับ', 120, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('2b1e100b-f2e2-50b8-8629-0053a9dfbefc', '3333be12-6bde-5692-b716-6079eb45b833', 'กระเทียม', 6, 'กลีบ');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('ff0f6715-9214-5fce-b883-9efc8db7d968', '3333be12-6bde-5692-b716-6079eb45b833', 'ซีอิ๊วขาว', 1, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('966c9f35-56ac-5811-b6a7-a38f4bc7b587', 'หมูทอดสมุนไพร', 'เมนูจากหมู', 40, 25, 'medium', ARRAY['เตาแก๊ส']::text[], 'หมักหมูกับสมุนไพร ทอดให้กรอบหอม', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('83dec227-8ced-5136-ada7-c89128ddb47e', '966c9f35-56ac-5811-b6a7-a38f4bc7b587', 'หมูสามชั้น', 150, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('efb7c870-da9f-5483-b013-a1f9ee8ba4db', '966c9f35-56ac-5811-b6a7-a38f4bc7b587', 'ตะไคร้', 1, 'ต้น');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('369a557a-15c1-5755-afc7-51f92d54b6e3', '966c9f35-56ac-5811-b6a7-a38f4bc7b587', 'ใบมะกรูด', 3, 'ใบ');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('8ddc2062-a0bb-58a1-b48f-c71241bdbb8f', 'แกงส้มผักรวมหมู', 'เมนูผัก', 35, 20, 'medium', ARRAY['เตาแก๊ส']::text[], 'ต้มน้ำพริกแกงส้มกับหมูและผักรวมจนสุก', 2, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('238bed8a-54c9-5172-96ab-c6dbb1994ac1', '8ddc2062-a0bb-58a1-b48f-c71241bdbb8f', 'หมูสับ', 100, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('70054b49-0310-5ff5-871d-2706599f9f80', '8ddc2062-a0bb-58a1-b48f-c71241bdbb8f', 'พริกแกงส้ม', 2, 'tbsp');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('6b1c20de-c547-5bdc-844b-e9b5b405e6ea', '8ddc2062-a0bb-58a1-b48f-c71241bdbb8f', 'ผักรวม', 150, 'g');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('a6801c31-a623-5fb5-81ca-71a708e2aba8', 'สลัดผักน้ำใส', 'เมนูผัก', 20, 10, 'easy', '{}'::text[], 'จัดผักสดหลากชนิดในจาน ราดน้ำสลัดใส', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('88c03516-dcd7-5ff2-8757-dd7b7b589370', 'a6801c31-a623-5fb5-81ca-71a708e2aba8', 'ผักสลัดรวม', 150, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('b81bffdc-2b68-580d-b850-92c802a55ab8', 'a6801c31-a623-5fb5-81ca-71a708e2aba8', 'มะเขือเทศ', 2, 'ลูก');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('979fcc57-9d12-58e1-b2fd-2ed79113ea4c', 'a6801c31-a623-5fb5-81ca-71a708e2aba8', 'น้ำสลัด', 2, 'tbsp');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('d3945c6b-e24c-5ab6-b049-07ea9e2c2e86', 'ผัดถั่วงอกเต้าหู้', 'เมนูผัก', 22, 10, 'easy', ARRAY['เตาแก๊ส']::text[], 'ผัดถั่วงอกกับเต้าหู้เหลืองหั่นเส้นและกุยช่าย', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('79ee4b63-e89e-59f8-918c-8f91e54bca57', 'd3945c6b-e24c-5ab6-b049-07ea9e2c2e86', 'ถั่วงอก', 150, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('1aa030cf-fb3e-5170-bd84-a77eb70087a3', 'd3945c6b-e24c-5ab6-b049-07ea9e2c2e86', 'เต้าหู้เหลือง', 1, 'ก้อน');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('9b6e6b47-130b-54fe-a5f2-bece3e424da4', 'd3945c6b-e24c-5ab6-b049-07ea9e2c2e86', 'กุยช่าย', 30, 'g');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('49c5962f-4f31-544a-8401-3db7c3b4c644', 'ข้าวไมโครเวฟผัดกะเพราไก่', 'เมนูที่ใช้ไมโครเวฟ', 35, 8, 'easy', ARRAY['ไมโครเวฟ']::text[], 'อุ่นข้าวกะเพราไก่พร้อมทานในไมโครเวฟ 3 นาที', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('903e9935-7ac9-58d5-85a2-cfd4f93bfbcf', '49c5962f-4f31-544a-8401-3db7c3b4c644', 'ข้าวกะเพราไก่พร้อมทาน', 300, 'g');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('96882d19-a0cf-5a1c-8fe7-688be05c938c', 'ข้าวต้มไมโครเวฟ', 'เมนูที่ใช้ไมโครเวฟ', 20, 10, 'easy', ARRAY['ไมโครเวฟ']::text[], 'ใส่ข้าวสวยและน้ำในถ้วยไมโครเวฟ อุ่นจนเดือด ใส่ไข่', 1, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('ba6e1bf3-ee16-559b-a836-b58ce0809a73', '96882d19-a0cf-5a1c-8fe7-688be05c938c', 'ข้าวสวย', 1, 'จาน');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('e01f738e-f347-5ecc-973c-fe7ae94d5175', '96882d19-a0cf-5a1c-8fe7-688be05c938c', 'น้ำเปล่า', 200, 'ml');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('86b07354-cc23-533c-ac22-e37a797e7231', '96882d19-a0cf-5a1c-8fe7-688be05c938c', 'ไข่ไก่', 1, 'ฟอง');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('f04f77d1-57e0-5e9c-a90f-3bcfba04d8a4', 'ข้าวหุงหมูสับใบกะเพรา', 'เมนูที่ใช้หม้อหุงข้าว', 35, 30, 'easy', ARRAY['หม้อหุงข้าว']::text[], 'ใส่ข้าวสาร หมูสับ และเครื่องปรุงลงหม้อหุงข้าว กดหุงพร้อมกัน', 2, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('9ce829ca-94fb-5c83-ae6c-1fc3d9337e81', 'f04f77d1-57e0-5e9c-a90f-3bcfba04d8a4', 'ข้าวสาร', 1, 'cup');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('0d8dba33-d7cc-5f85-92f3-138a51d6b204', 'f04f77d1-57e0-5e9c-a90f-3bcfba04d8a4', 'หมูสับ', 150, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('7d9b5545-d795-5241-8541-956c443a88c3', 'f04f77d1-57e0-5e9c-a90f-3bcfba04d8a4', 'ใบกะเพรา', 0.5, 'กำ');

insert into public.meal_templates (id, name, category, estimated_price_per_serving, prep_minutes, difficulty, required_equipment, steps, serving_count, is_active) values ('44a28eca-f6ee-5f1a-b554-4d2b86e49e84', 'ข้าวหุงไก่เห็ดหอม', 'เมนูที่ใช้หม้อหุงข้าว', 40, 35, 'easy', ARRAY['หม้อหุงข้าว']::text[], 'ใส่ข้าวสาร ไก่ เห็ดหอม และซีอิ๊วลงหม้อหุงข้าว กดหุง', 2, true);
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('1807a34f-f734-5552-a67b-218b883e246b', '44a28eca-f6ee-5f1a-b554-4d2b86e49e84', 'ข้าวสาร', 1, 'cup');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('29bef68f-2792-5111-b6d8-e8af6a4907fe', '44a28eca-f6ee-5f1a-b554-4d2b86e49e84', 'ไก่', 120, 'g');
insert into public.meal_template_ingredients (id, meal_template_id, ingredient_name, quantity, unit) values ('67a9e80a-4e6a-563e-bf2f-c79cb5285581', '44a28eca-f6ee-5f1a-b554-4d2b86e49e84', 'เห็ดหอม', 4, 'ดอก');
