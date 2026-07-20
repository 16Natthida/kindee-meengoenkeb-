create table public.recurring_expenses (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid references public.budget_categories(id) on delete set null,
  title text not null check (char_length(trim(title)) > 0),
  amount numeric(12,2) not null check (amount > 0),
  payment_method text not null default 'cash'
    check (payment_method in ('cash','transfer','debit_card','credit_card','promptpay','other')),
  note text,
  frequency text not null default 'monthly' check (frequency in ('weekly','monthly')),
  next_run_date date not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_recurring_expenses_user_active
  on public.recurring_expenses (user_id, is_active, next_run_date);

create trigger trg_recurring_expenses_updated_at
  before update on public.recurring_expenses
  for each row execute function public.set_updated_at();

alter table public.recurring_expenses enable row level security;

create policy "recurring_expenses_select_own" on public.recurring_expenses
  for select using (auth.uid() = user_id);
create policy "recurring_expenses_insert_own" on public.recurring_expenses
  for insert with check (auth.uid() = user_id);
create policy "recurring_expenses_update_own" on public.recurring_expenses
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "recurring_expenses_delete_own" on public.recurring_expenses
  for delete using (auth.uid() = user_id);
