# 灵感日记：Supabase 云同步配置

当前阶段：网页仍使用本地存储。完成本指南并配置项目后，再接入登录和同步前端。不要把任何服务端密钥提交到 GitHub。

## 方案与安全边界

- Supabase Auth：邮箱注册/登录。
- Postgres：每个用户一行云端备份，保存灵感、日记、分类和正式作品。
- Row Level Security (RLS)：用户只能读取、写入自己的那一行。
- 前端只允许使用 Project URL 和 publishable/anon key。**绝不能**把 `service_role` / secret key 放进网页、GitHub 仓库或 APK。
- 本地存储继续作为离线缓存；初次绑定时先让用户选择“上传本机数据”或“下载云端数据”，绝不静默覆盖。

## 第一步：创建 Supabase 项目

1. 打开 https://supabase.com/ ，登录并创建一个新项目。
2. 记下项目的 **Project URL** 和 **publishable key**（旧项目可能显示 anon public key）。它们是浏览器端公开配置，不是数据库密码。
3. 设置 Authentication → URL Configuration：
   - Site URL：`https://remmyshany14-maker.github.io/my-first-app/`
   - Redirect URLs 添加：`https://remmyshany14-maker.github.io/my-first-app/**`
4. Authentication → Providers 中启用 Email。可以先用邮箱验证码/魔法链接；若用邮件链接，确认回跳地址在 Redirect URLs 允许列表中。

## 第二步：创建用户隔离的数据表

在 Supabase → SQL Editor → New query 中运行下面的 SQL：

```sql
create table if not exists public.user_documents (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.user_documents enable row level security;

revoke all on public.user_documents from anon;
grant select, insert, update, delete on public.user_documents to authenticated;

drop policy if exists "read own document" on public.user_documents;
create policy "read own document"
on public.user_documents for select to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "insert own document" on public.user_documents;
create policy "insert own document"
on public.user_documents for insert to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "update own document" on public.user_documents;
create policy "update own document"
on public.user_documents for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "delete own document" on public.user_documents;
create policy "delete own document"
on public.user_documents for delete to authenticated
using ((select auth.uid()) = user_id);
```

## 第三步：把公开配置提供给网页

需要提供给前端的只有：
- Project URL，例如 `https://xxxx.supabase.co`
- publishable key（或旧版 anon public key）

不要发送或提交数据库密码、SMTP 密码、JWT secret、`service_role` / secret key。

拿到 URL 和公开 key 后，才能把登录界面、云端读写、初次迁移向导和冲突保护接入网页。没有这两个值时，网页应保持本地模式，不应显示“已同步”。

## 第四步：上线前验收

- 未登录用户无法读取云端数据。
- 账号 A 无法读写账号 B 的数据。
- 新设备登录时，先显示本地/云端记录数量，再让用户选择合并或以一方为准。
- 两台设备同时编辑时，检测云端版本冲突，不静默覆盖。
- 退出登录不删除本地数据。
- 断网时可继续本地写作，恢复网络后再同步。
- 导出备份仍可用，云同步不是备份的替代品。

## 当前限制

目前的网页还未连接 Supabase，也没有启用云同步。只完成项目配置与 SQL 后，仍需把公开配置接入前端，并实现 Auth、同步队列和冲突检测；不能仅凭创建数据库就认为同步已经生效。
