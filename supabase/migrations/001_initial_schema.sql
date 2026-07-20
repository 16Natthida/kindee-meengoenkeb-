-- ============================================================
-- กินดี มีเงินเก็บ - Initial Schema
-- ============================================================
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ============================================================
-- 1. profiles
-- ============================================================
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  email text not null,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- 2. user_settings
-- ============================================================
create table public.user_settings (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  theme_mode text not null default 'system' check (theme_mode in ('light','dark','system')),
  currency text not null default 'THB',
  notify_budget_low boolean not null default true,
  notify_expiry boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id)
);

-- ============================================================
-- 3. monthly_incomes
-- ============================================================
create table public.monthly_incomes (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  month int not null check (month between 1 and 12),
  year int not null check (year between 2000 and 2100),
  salary numeric(12,2) not null default 0 check (salary >= 0),
  extra_income numeric(12,2) not null default 0 check (extra_income >= 0),
  income_date date,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, month, year)
);

-- ============================================================
-- 4. budget_categories (หมวดของผู้ใช้แต่ละคน)
-- ============================================================
create table public.budget_categories (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  icon text not null default 'category',
  is_default boolean not null default false,
  is_hidden boolean not null default false,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- 5. monthly_budgets (การแบ่งเงินของแต่ละหมวดในแต่ละเดือน)
-- ============================================================
create table public.monthly_budgets (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  income_id uuid not null references public.monthly_incomes(id) on delete cascade,
  category_id uuid not null references public.budget_categories(id) on delete cascade,
  allocation_type text not null default 'percentage' check (allocation_type in ('percentage','fixed')),
  percentage numeric(5,2) check (percentage >= 0 and percentage <= 100),
  amount numeric(12,2) not null default 0 check (amount >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (income_id, category_id)
);

-- ============================================================
-- 6. expenses
-- ============================================================
create table public.expenses (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid references public.budget_categories(id) on delete set null,
  title text not null check (char_length(trim(title)) > 0),
  amount numeric(12,2) not null check (amount > 0),
  payment_method text not null default 'cash'
    check (payment_method in ('cash','transfer','debit_card','credit_card','promptpay','other')),
  note text,
  receipt_image_url text,
  expense_date date not null default current_date,
  expense_time time,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_expenses_user_date on public.expenses (user_id, expense_date desc);
create index idx_expenses_user_category on public.expenses (user_id, category_id);

-- ============================================================
-- 7. meal_preferences
-- ============================================================
create table public.meal_preferences (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  people_count int not null default 1 check (people_count > 0),
  meals_per_day int not null default 3 check (meals_per_day > 0),
  daily_food_budget numeric(12,2) check (daily_food_budget >= 0),
  weekly_food_budget numeric(12,2) check (weekly_food_budget >= 0),
  monthly_food_budget numeric(12,2) check (monthly_food_budget >= 0),
  cooking_style text not null default 'cook' check (cooking_style in ('cook','buy','mixed')),
  disliked_foods text[] not null default '{}',
  allergies text[] not null default '{}',
  available_equipment text[] not null default '{}',
  available_cook_minutes int,
  preferred_difficulty text default 'easy' check (preferred_difficulty in ('easy','medium','hard')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id)
);

-- ============================================================
-- 8. meal_templates (ฐานข้อมูลเมนูกลาง - ผู้ใช้ทุกคนอ่านได้)
-- ============================================================
create table public.meal_templates (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  category text not null,
  estimated_price_per_serving numeric(12,2) not null check (estimated_price_per_serving >= 0),
  prep_minutes int not null default 15,
  difficulty text not null default 'easy' check (difficulty in ('easy','medium','hard')),
  required_equipment text[] not null default '{}',
  steps text not null,
  serving_count int not null default 1,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- 9. meal_template_ingredients
-- ============================================================
create table public.meal_template_ingredients (
  id uuid primary key default uuid_generate_v4(),
  meal_template_id uuid not null references public.meal_templates(id) on delete cascade,
  ingredient_name text not null,
  quantity numeric(12,2) not null check (quantity > 0),
  unit text not null,
  created_at timestamptz not null default now()
);

create index idx_mti_template on public.meal_template_ingredients (meal_template_id);

-- ============================================================
-- 10. meal_plans
-- ============================================================
create table public.meal_plans (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_type text not null default 'daily' check (plan_type in ('daily','weekly','monthly')),
  start_date date not null,
  end_date date not null,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_date >= start_date)
);

-- ============================================================
-- 11. meal_plan_items
-- ============================================================
create table public.meal_plan_items (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  meal_plan_id uuid not null references public.meal_plans(id) on delete cascade,
  meal_template_id uuid references public.meal_templates(id) on delete set null,
  meal_date date not null,
  meal_type text not null check (meal_type in ('breakfast','lunch','dinner','snack')),
  custom_name text,
  is_homemade boolean not null default true,
  people_count int not null default 1 check (people_count > 0),
  estimated_price numeric(12,2) not null default 0 check (estimated_price >= 0),
  prep_minutes int,
  difficulty text default 'easy' check (difficulty in ('easy','medium','hard')),
  status text not null default 'pending' check (status in ('pending','done')),
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_mpi_user_date on public.meal_plan_items (user_id, meal_date);

-- ============================================================
-- 12. ingredients (คลังวัตถุดิบของผู้ใช้)
-- ============================================================
create table public.ingredients (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  category text not null default 'other'
    check (category in ('meat','egg','vegetable','fruit','seasoning','dry_food','frozen_food','beverage','other')),
  quantity numeric(12,2) not null default 0 check (quantity >= 0),
  unit text not null,
  minimum_quantity numeric(12,2) not null default 0 check (minimum_quantity >= 0),
  purchase_date date,
  expiry_date date,
  purchase_price numeric(12,2) check (purchase_price >= 0),
  storage_location text not null default 'fridge'
    check (storage_location in ('fridge','freezer','shelf','kitchen','other')),
  image_url text,
  note text,
  status text not null default 'available'
    check (status in ('available','low','expiring_soon','expired','out_of_stock')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_ingredients_user on public.ingredients (user_id);
create index idx_ingredients_expiry on public.ingredients (user_id, expiry_date);

-- ============================================================
-- 13. shopping_lists
-- ============================================================
create table public.shopping_lists (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null default 'รายการซื้อของ',
  meal_plan_id uuid references public.meal_plans(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- 14. shopping_list_items
-- ============================================================
create table public.shopping_list_items (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  shopping_list_id uuid not null references public.shopping_lists(id) on delete cascade,
  product_name text not null check (char_length(trim(product_name)) > 0),
  quantity numeric(12,2) not null default 1 check (quantity > 0),
  unit text not null default 'ชิ้น',
  estimated_price numeric(12,2) check (estimated_price >= 0),
  actual_price numeric(12,2) check (actual_price >= 0),
  category text,
  store_name text,
  is_purchased boolean not null default false,
  due_date date,
  note text,
  linked_to_meal_plan boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_sli_list on public.shopping_list_items (shopping_list_id);

-- ============================================================
-- 15. notifications
-- ============================================================
create table public.notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  detail text not null,
  type text not null check (type in (
    'budget_low','over_budget','food_budget_low','ingredient_expiring',
    'ingredient_expired','ingredient_low','no_meal_plan',
    'shopping_incomplete','expense_above_average'
  )),
  is_read boolean not null default false,
  reference_id uuid,
  created_at timestamptz not null default now()
);

create index idx_notifications_user_unread on public.notifications (user_id, is_read);

-- ============================================================
-- Trigger: updated_at auto-update
-- ============================================================
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

do $$
declare t text;
begin
  for t in
    select unnest(array[
      'profiles','user_settings','monthly_incomes','budget_categories',
      'monthly_budgets','expenses','meal_preferences','meal_templates',
      'meal_plans','meal_plan_items','ingredients','shopping_lists',
      'shopping_list_items'
    ])
  loop
    execute format(
      'create trigger trg_%I_updated_at before update on public.%I
       for each row execute function public.set_updated_at();', t, t
    );
  end loop;
end $$;

-- ============================================================
-- Trigger: สร้าง Profile + default budget categories หลังสมัครสมาชิก
-- ============================================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)),
    new.email
  );

  insert into public.user_settings (user_id) values (new.id);

  insert into public.budget_categories (user_id, name, icon, is_default, sort_order)
  values
    (new.id, 'ค่าใช้จ่ายจำเป็น', 'home', true, 1),
    (new.id, 'ค่าอาหาร', 'restaurant', true, 2),
    (new.id, 'ค่าเดินทาง', 'directions_car', true, 3),
    (new.id, 'ชำระหนี้', 'credit_card', true, 4),
    (new.id, 'เงินเก็บ', 'savings', true, 5),
    (new.id, 'เงินฉุกเฉิน', 'health_and_safety', true, 6),
    (new.id, 'เงินใช้ส่วนตัว', 'person', true, 7),
    (new.id, 'อื่น ๆ', 'category', true, 8);

  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- Storage buckets
-- ============================================================
insert into storage.buckets (id, name, public)
values ('receipts', 'receipts', false)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('ingredient-images', 'ingredient-images', false)
on conflict (id) do nothing;
