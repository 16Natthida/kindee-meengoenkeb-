-- ============================================================
-- Row Level Security - เปิดใช้งานทุกตารางข้อมูลผู้ใช้
-- ============================================================
alter table public.profiles enable row level security;
alter table public.user_settings enable row level security;
alter table public.monthly_incomes enable row level security;
alter table public.budget_categories enable row level security;
alter table public.monthly_budgets enable row level security;
alter table public.expenses enable row level security;
alter table public.meal_preferences enable row level security;
alter table public.meal_plans enable row level security;
alter table public.meal_plan_items enable row level security;
alter table public.ingredients enable row level security;
alter table public.shopping_lists enable row level security;
alter table public.shopping_list_items enable row level security;
alter table public.notifications enable row level security;

-- ตารางกลาง (เมนูมาตรฐาน) - อ่านได้ทุกคน แก้ไขไม่ได้
alter table public.meal_templates enable row level security;
alter table public.meal_template_ingredients enable row level security;

-- ============================================================
-- Generic pattern (user_id = auth.uid()) สำหรับแต่ละตาราง
-- ============================================================

-- profiles: id คือ user id เอง
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);
-- insert ทำผ่าน trigger (security definer) เท่านั้น ไม่เปิด insert policy ให้ client

-- user_settings
create policy "user_settings_select_own" on public.user_settings
  for select using (auth.uid() = user_id);
create policy "user_settings_insert_own" on public.user_settings
  for insert with check (auth.uid() = user_id);
create policy "user_settings_update_own" on public.user_settings
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "user_settings_delete_own" on public.user_settings
  for delete using (auth.uid() = user_id);

-- monthly_incomes
create policy "monthly_incomes_select_own" on public.monthly_incomes
  for select using (auth.uid() = user_id);
create policy "monthly_incomes_insert_own" on public.monthly_incomes
  for insert with check (auth.uid() = user_id);
create policy "monthly_incomes_update_own" on public.monthly_incomes
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "monthly_incomes_delete_own" on public.monthly_incomes
  for delete using (auth.uid() = user_id);

-- budget_categories
create policy "budget_categories_select_own" on public.budget_categories
  for select using (auth.uid() = user_id);
create policy "budget_categories_insert_own" on public.budget_categories
  for insert with check (auth.uid() = user_id);
create policy "budget_categories_update_own" on public.budget_categories
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "budget_categories_delete_own" on public.budget_categories
  for delete using (auth.uid() = user_id);

-- monthly_budgets
create policy "monthly_budgets_select_own" on public.monthly_budgets
  for select using (auth.uid() = user_id);
create policy "monthly_budgets_insert_own" on public.monthly_budgets
  for insert with check (auth.uid() = user_id);
create policy "monthly_budgets_update_own" on public.monthly_budgets
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "monthly_budgets_delete_own" on public.monthly_budgets
  for delete using (auth.uid() = user_id);

-- expenses
create policy "expenses_select_own" on public.expenses
  for select using (auth.uid() = user_id);
create policy "expenses_insert_own" on public.expenses
  for insert with check (auth.uid() = user_id);
create policy "expenses_update_own" on public.expenses
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "expenses_delete_own" on public.expenses
  for delete using (auth.uid() = user_id);

-- meal_preferences
create policy "meal_preferences_select_own" on public.meal_preferences
  for select using (auth.uid() = user_id);
create policy "meal_preferences_insert_own" on public.meal_preferences
  for insert with check (auth.uid() = user_id);
create policy "meal_preferences_update_own" on public.meal_preferences
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "meal_preferences_delete_own" on public.meal_preferences
  for delete using (auth.uid() = user_id);

-- meal_plans
create policy "meal_plans_select_own" on public.meal_plans
  for select using (auth.uid() = user_id);
create policy "meal_plans_insert_own" on public.meal_plans
  for insert with check (auth.uid() = user_id);
create policy "meal_plans_update_own" on public.meal_plans
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "meal_plans_delete_own" on public.meal_plans
  for delete using (auth.uid() = user_id);

-- meal_plan_items
create policy "meal_plan_items_select_own" on public.meal_plan_items
  for select using (auth.uid() = user_id);
create policy "meal_plan_items_insert_own" on public.meal_plan_items
  for insert with check (auth.uid() = user_id);
create policy "meal_plan_items_update_own" on public.meal_plan_items
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "meal_plan_items_delete_own" on public.meal_plan_items
  for delete using (auth.uid() = user_id);

-- ingredients
create policy "ingredients_select_own" on public.ingredients
  for select using (auth.uid() = user_id);
create policy "ingredients_insert_own" on public.ingredients
  for insert with check (auth.uid() = user_id);
create policy "ingredients_update_own" on public.ingredients
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "ingredients_delete_own" on public.ingredients
  for delete using (auth.uid() = user_id);

-- shopping_lists
create policy "shopping_lists_select_own" on public.shopping_lists
  for select using (auth.uid() = user_id);
create policy "shopping_lists_insert_own" on public.shopping_lists
  for insert with check (auth.uid() = user_id);
create policy "shopping_lists_update_own" on public.shopping_lists
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "shopping_lists_delete_own" on public.shopping_lists
  for delete using (auth.uid() = user_id);

-- shopping_list_items
create policy "shopping_list_items_select_own" on public.shopping_list_items
  for select using (auth.uid() = user_id);
create policy "shopping_list_items_insert_own" on public.shopping_list_items
  for insert with check (auth.uid() = user_id);
create policy "shopping_list_items_update_own" on public.shopping_list_items
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "shopping_list_items_delete_own" on public.shopping_list_items
  for delete using (auth.uid() = user_id);

-- notifications
create policy "notifications_select_own" on public.notifications
  for select using (auth.uid() = user_id);
create policy "notifications_insert_own" on public.notifications
  for insert with check (auth.uid() = user_id);
create policy "notifications_update_own" on public.notifications
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "notifications_delete_own" on public.notifications
  for delete using (auth.uid() = user_id);

-- ============================================================
-- meal_templates / meal_template_ingredients: อ่านได้ทุกคนที่ login, ห้ามแก้ไข
-- (การเขียนทำผ่าน service role / seed เท่านั้น จึงไม่มี insert/update/delete policy ให้ client)
-- ============================================================
create policy "meal_templates_select_all" on public.meal_templates
  for select using (auth.role() = 'authenticated');

create policy "meal_template_ingredients_select_all" on public.meal_template_ingredients
  for select using (auth.role() = 'authenticated');

-- ============================================================
-- Storage Policies
-- โครงสร้าง path ที่บังคับใช้จาก Flutter: {bucket}/{user_id}/{filename}
-- ============================================================
create policy "receipts_select_own"
  on storage.objects for select
  using (bucket_id = 'receipts' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "receipts_insert_own"
  on storage.objects for insert
  with check (bucket_id = 'receipts' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "receipts_update_own"
  on storage.objects for update
  using (bucket_id = 'receipts' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "receipts_delete_own"
  on storage.objects for delete
  using (bucket_id = 'receipts' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "ingredient_images_select_own"
  on storage.objects for select
  using (bucket_id = 'ingredient-images' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "ingredient_images_insert_own"
  on storage.objects for insert
  with check (bucket_id = 'ingredient-images' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "ingredient_images_update_own"
  on storage.objects for update
  using (bucket_id = 'ingredient-images' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "ingredient_images_delete_own"
  on storage.objects for delete
  using (bucket_id = 'ingredient-images' and (storage.foldername(name))[1] = auth.uid()::text);
