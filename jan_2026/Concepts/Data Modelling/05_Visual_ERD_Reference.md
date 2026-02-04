# LinkedIn Data Model - Visual Reference

## Entity Relationship Diagram (Text Format)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LINKEDIN DATA MODEL                                  │
│                         (Basic Level - 11 Tables)                           │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│      USERS           │
├──────────────────────┤
│ 🔑 user_id          │──┐
│    first_name        │  │
│    last_name         │  │
│    email (UNIQUE)    │  │
│    password_hash     │  │
│    headline          │  │
│    profile_photo_url │  │
│    location          │  │
│    about             │  │
│    created_at        │  │
│    updated_at        │  │
│    is_active         │  │
└──────────────────────┘  │
         │                │
         │ 1              │
         │                │
         │ N              │
         ↓                │
┌──────────────────────┐  │
│      POSTS           │  │
├──────────────────────┤  │
│ 🔑 post_id          │  │
│ 🔗 user_id          │──┘
│    content           │
│    image_url         │
│    video_url         │
│    created_at        │
│    updated_at        │
│    is_deleted        │
└──────────────────────┘
         │
         │ 1
         │
         ├──────────────────┬──────────────────┐
         │ N                │ N                │
         ↓                  ↓                  │
┌──────────────────────┐  ┌──────────────────────┐
│     COMMENTS         │  │       LIKES          │
├──────────────────────┤  ├──────────────────────┤
│ 🔑 comment_id       │  │ 🔑 like_id          │
│ 🔗 post_id          │  │ 🔗 post_id          │
│ 🔗 user_id          │  │ 🔗 user_id          │
│    content           │  │    created_at        │
│    created_at        │  └──────────────────────┘
│    updated_at        │
│    is_deleted        │
└──────────────────────┘


┌──────────────────────┐         ┌──────────────────────┐
│    CONNECTIONS       │         │     MESSAGES         │
│  (Self-Referencing)  │         │  (Self-Referencing)  │
├──────────────────────┤         ├──────────────────────┤
│ 🔑 connection_id    │         │ 🔑 message_id       │
│ 🔗 user_id_1        │─┐       │ 🔗 sender_id        │─┐
│ 🔗 user_id_2        │─┤       │ 🔗 receiver_id      │─┤
│    status            │ │       │    content           │ │
│    requested_at      │ │       │    sent_at           │ │
│    accepted_at       │ │       │    is_read           │ │
└──────────────────────┘ │       │    read_at           │ │
         │               │       └──────────────────────┘ │
         └───────────────┴────────────────────────────────┘
                         │
                    Both reference
                      USERS table


┌──────────────────────┐         ┌──────────────────────┐
│  WORK_EXPERIENCE     │         │     COMPANIES        │
├──────────────────────┤         ├──────────────────────┤
│ 🔑 experience_id    │         │ 🔑 company_id       │
│ 🔗 user_id          │         │    company_name      │
│ 🔗 company_id       │────────→│    industry          │
│    job_title         │         │    company_size      │
│    employment_type   │         │    headquarters      │
│    start_date        │         │    website           │
│    end_date          │         │    description       │
│    description       │         │    logo_url          │
│    is_current        │         │    founded_year      │
└──────────────────────┘         │    created_at        │
         │                       └──────────────────────┘
         │
         └──────────→ USERS


┌──────────────────────┐
│     EDUCATION        │
├──────────────────────┤
│ 🔑 education_id     │
│ 🔗 user_id          │────────→ USERS
│    institution_name  │
│    degree            │
│    field_of_study    │
│    start_year        │
│    end_year          │
│    grade             │
│    description       │
└──────────────────────┘


┌──────────────────────┐         ┌──────────────────────┐         ┌──────────────────────┐
│       USERS          │         │    USER_SKILLS       │         │       SKILLS         │
│                      │         │  (Junction Table)    │         │   (Master List)      │
├──────────────────────┤         ├──────────────────────┤         ├──────────────────────┤
│ 🔑 user_id          │←────────│ 🔑 user_skill_id    │         │ 🔑 skill_id         │
│    ...               │    1    │ 🔗 user_id          │    N    │    skill_name        │
└──────────────────────┘         │ 🔗 skill_id         │────────→│    category          │
                            N    │    proficiency_level │    1    └──────────────────────┘
                                 │    years_of_exp      │
                                 │    endorsed_count    │
                                 └──────────────────────┘

                         MANY-TO-MANY RELATIONSHIP
                    (Users can have many Skills, Skills belong to many Users)
```

---

## Relationship Summary

### One-to-Many (1:N) Relationships:

1. **USERS → POSTS**
   - One user creates many posts
   - `posts.user_id` → `users.user_id`

2. **USERS → COMMENTS**
   - One user writes many comments
   - `comments.user_id` → `users.user_id`

3. **POSTS → COMMENTS**
   - One post has many comments
   - `comments.post_id` → `posts.post_id`

4. **USERS → LIKES**
   - One user likes many posts
   - `likes.user_id` → `users.user_id`

5. **POSTS → LIKES**
   - One post has many likes
   - `likes.post_id` → `posts.post_id`

6. **USERS → WORK_EXPERIENCE**
   - One user has many jobs
   - `work_experience.user_id` → `users.user_id`

7. **COMPANIES → WORK_EXPERIENCE**
   - One company has many employees
   - `work_experience.company_id` → `companies.company_id`

8. **USERS → EDUCATION**
   - One user has many education records
   - `education.user_id` → `users.user_id`

---

### Many-to-Many (M:N) Relationships:

1. **USERS ↔ SKILLS** (via USER_SKILLS junction table)
   - Many users have many skills
   - `user_skills.user_id` → `users.user_id`
   - `user_skills.skill_id` → `skills.skill_id`

2. **USERS ↔ USERS** (via CONNECTIONS - self-referencing)
   - Many users connect with many users
   - `connections.user_id_1` → `users.user_id`
   - `connections.user_id_2` → `users.user_id`

---

### Self-Referencing Relationships:

1. **CONNECTIONS**
   - Users connect with other users
   - Both `user_id_1` and `user_id_2` reference `users` table

2. **MESSAGES**
   - Users send messages to other users
   - Both `sender_id` and `receiver_id` reference `users` table

---

## Table Details

### Core Tables (3):
- **USERS**: Central entity, user profiles
- **COMPANIES**: Organization information
- **SKILLS**: Master list of professional skills

### Content Tables (3):
- **POSTS**: User-generated content
- **COMMENTS**: Responses to posts
- **LIKES**: Reactions to posts

### Relationship Tables (3):
- **CONNECTIONS**: User network (junction table)
- **USER_SKILLS**: User-skill mapping (junction table)
- **MESSAGES**: Direct messaging

### Profile Tables (2):
- **WORK_EXPERIENCE**: Job history
- **EDUCATION**: Academic credentials

---

## Key Constraints

### Primary Keys (🔑):
- Every table has a surrogate primary key
- Auto-incrementing integers
- Named as `{table_name}_id`

### Foreign Keys (🔗):
- Enforce referential integrity
- ON DELETE CASCADE for dependent data
- ON DELETE SET NULL for optional relationships

### Unique Constraints:
- `users.email` - One email per user
- `likes(user_id, post_id)` - One like per user per post
- `user_skills(user_id, skill_id)` - One skill entry per user
- `connections(user_id_1, user_id_2)` - No duplicate connections

### Check Constraints:
- `connections`: user_id_1 ≠ user_id_2 (can't connect to self)
- `messages`: sender_id ≠ receiver_id (can't message self)
- `work_experience`: start_date < end_date

---

## Indexes for Performance

### Recommended Indexes:

```sql
-- Users table
INDEX idx_email (email)
INDEX idx_name (first_name, last_name)

-- Posts table
INDEX idx_user_id (user_id)
INDEX idx_created_at (created_at)

-- Comments table
INDEX idx_post_id (post_id)
INDEX idx_user_id (user_id)

-- Likes table
INDEX idx_post_id (post_id)
INDEX idx_user_id (user_id)

-- Connections table
INDEX idx_user1 (user_id_1)
INDEX idx_user2 (user_id_2)
INDEX idx_status (status)

-- Work Experience table
INDEX idx_user_id (user_id)
INDEX idx_company_id (company_id)

-- User Skills table
INDEX idx_user_id (user_id)
INDEX idx_skill_id (skill_id)

-- Messages table
INDEX idx_sender (sender_id)
INDEX idx_receiver (receiver_id)
```

---

## Data Flow Examples

### Example 1: Creating a Post

```
User writes post
     ↓
INSERT into POSTS (user_id, content)
     ↓
Other users see post
     ↓
Users can LIKE (INSERT into LIKES)
     ↓
Users can COMMENT (INSERT into COMMENTS)
```

### Example 2: Making a Connection

```
User A sends connection request to User B
     ↓
INSERT into CONNECTIONS (user_id_1, user_id_2, status='pending')
     ↓
User B receives notification
     ↓
User B accepts
     ↓
UPDATE CONNECTIONS SET status='accepted', accepted_at=NOW()
     ↓
Users can now message each other
```

### Example 3: Building Profile

```
User creates account
     ↓
INSERT into USERS
     ↓
Add work experience
     ↓
INSERT into WORK_EXPERIENCE (user_id, company_id, ...)
     ↓
Add education
     ↓
INSERT into EDUCATION (user_id, ...)
     ↓
Add skills
     ↓
INSERT into USER_SKILLS (user_id, skill_id, ...)
```

---

## Normalization Level

This schema is in **Third Normal Form (3NF)**:

✅ **1NF**: All attributes are atomic
✅ **2NF**: No partial dependencies
✅ **3NF**: No transitive dependencies

**Example of 3NF**:
- ❌ Storing `company_name` in `work_experience` table
- ✅ Storing `company_id` and looking up name in `companies` table

---

## Scalability Considerations

### For Production:

1. **Partitioning**:
   - Partition `posts` by date (monthly/yearly)
   - Partition `messages` by date
   - Partition `likes` by post_id range

2. **Sharding**:
   - Shard users by user_id range
   - Shard posts by user_id (co-locate user data)

3. **Caching**:
   - Cache user profiles (Redis)
   - Cache connection lists
   - Cache post engagement counts

4. **Denormalization** (when needed):
   - Store `like_count` in posts table
   - Store `comment_count` in posts table
   - Store `connection_count` in users table

5. **Read Replicas**:
   - Separate read and write databases
   - Route queries to read replicas

---

## Common Queries

### Get User Profile with Stats:
```sql
SELECT u.*, 
       COUNT(DISTINCT p.post_id) as post_count,
       COUNT(DISTINCT c.connection_id) as connection_count
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
LEFT JOIN connections c ON (u.user_id = c.user_id_1 OR u.user_id = c.user_id_2)
WHERE u.user_id = ?
GROUP BY u.user_id;
```

### Get News Feed:
```sql
SELECT p.*, u.first_name, u.last_name,
       COUNT(DISTINCT l.like_id) as likes,
       COUNT(DISTINCT c.comment_id) as comments
FROM posts p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
WHERE p.user_id IN (
    SELECT CASE 
        WHEN user_id_1 = ? THEN user_id_2
        ELSE user_id_1
    END
    FROM connections
    WHERE (user_id_1 = ? OR user_id_2 = ?) AND status = 'accepted'
)
GROUP BY p.post_id
ORDER BY p.created_at DESC
LIMIT 20;
```

---

## Legend

- 🔑 = Primary Key
- 🔗 = Foreign Key
- → = One-to-Many relationship
- ↔ = Many-to-Many relationship
- UNIQUE = Unique constraint
- INDEX = Database index

---

This visual reference complements the SQL schema and helps understand the overall structure at a glance!
