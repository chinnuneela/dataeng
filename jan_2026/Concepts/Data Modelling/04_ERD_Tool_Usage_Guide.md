# How to Use LinkedIn Schema with ERD Tool

## Step-by-Step Guide for https://erd.dbdesigner.net/

### Method 1: Import SQL File (Recommended)

1. **Open the ERD Tool**
   - Navigate to: https://erd.dbdesigner.net/
   - You'll see a blank canvas

2. **Import the SQL Schema**
   - Click on **"Import"** button (usually in top menu)
   - Select **"From SQL"** or **"Import SQL"**
   - Copy the entire content from `03_LinkedIn_Schema.sql`
   - Paste into the import dialog
   - Click **"Import"** or **"Execute"**

3. **Auto-Arrange the Diagram**
   - After import, tables will appear on canvas
   - Click **"Auto Arrange"** or **"Auto Layout"** to organize tables
   - Drag tables to customize layout

4. **View Relationships**
   - Foreign key relationships will be shown as connecting lines
   - Hover over lines to see relationship details
   - Different line styles indicate different relationship types

---

### Method 2: Manual Table Creation (If Import Doesn't Work)

If the import feature doesn't work, you can create tables manually:

1. **Create Each Table**
   - Click **"Add Table"** button
   - Name the table (e.g., "users")
   - Add columns one by one with data types

2. **Define Primary Keys**
   - Select the column (e.g., user_id)
   - Mark as **Primary Key** (usually a key icon)

3. **Create Relationships**
   - Click on foreign key column in child table
   - Drag to primary key in parent table
   - This creates the relationship line

---

## Understanding the ERD Visualization

### Table Components

Each table box shows:
```
┌─────────────────────────────┐
│ TABLE_NAME                  │
├─────────────────────────────┤
│ 🔑 primary_key INT          │
│    column_name VARCHAR(50)  │
│    foreign_key INT          │
│    created_at TIMESTAMP     │
└─────────────────────────────┘
```

**Symbols**:
- 🔑 = Primary Key
- 🔗 = Foreign Key
- ⚡ = Index
- ⭐ = Unique constraint

---

### Relationship Lines

**One-to-Many (1:N)**:
```
users ────────< posts
  1              N
```
- One user has many posts
- Line from users to posts
- "Crow's foot" on posts side

**Many-to-Many (M:N)**:
```
users >────< skills
  M     junction    N
        table
```
- Requires junction table (user_skills)
- Two 1:N relationships

**One-to-One (1:1)**:
```
users ──────── user_profiles
  1              1
```
- Single line, no crow's foot

---

## Tables in the LinkedIn Model

### Core Tables (11 total):

1. **users** - User profiles
2. **companies** - Organization information
3. **posts** - User content
4. **comments** - Post comments
5. **likes** - Post likes
6. **connections** - User connections (self-referencing)
7. **work_experience** - Job history
8. **education** - Academic background
9. **skills** - Master skill list
10. **user_skills** - User-skill junction table
11. **messages** - Direct messages

---

## Key Relationships to Observe

### 1. Users → Posts (1:N)
- One user creates many posts
- Foreign key: `posts.user_id` → `users.user_id`

### 2. Posts → Comments (1:N)
- One post has many comments
- Foreign key: `comments.post_id` → `posts.post_id`

### 3. Users ↔ Skills (M:N)
- Many-to-many via `user_skills` junction table
- `user_skills.user_id` → `users.user_id`
- `user_skills.skill_id` → `skills.skill_id`

### 4. Users ↔ Users (M:N Self-Referencing)
- Via `connections` table
- `connections.user_id_1` → `users.user_id`
- `connections.user_id_2` → `users.user_id`

### 5. Users → Work Experience → Companies
- Chain relationship
- `work_experience.user_id` → `users.user_id`
- `work_experience.company_id` → `companies.company_id`

---

## Sample Data Included

The SQL file includes sample data for:
- ✅ 5 sample users
- ✅ 5 sample companies
- ✅ 5 sample posts
- ✅ 5 sample comments
- ✅ Multiple likes
- ✅ Connections between users
- ✅ Work experience records
- ✅ Education records
- ✅ Skills and user-skill mappings
- ✅ Sample messages

---

## Testing the Schema

### After Import, Try These Queries:

**1. View all users:**
```sql
SELECT * FROM users;
```

**2. Get posts with engagement:**
```sql
SELECT p.content, 
       COUNT(DISTINCT l.like_id) as likes,
       COUNT(DISTINCT c.comment_id) as comments
FROM posts p
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id;
```

**3. Get user's connections:**
```sql
SELECT u2.first_name, u2.last_name, u2.headline
FROM connections c
JOIN users u2 ON (c.user_id_2 = u2.user_id)
WHERE c.user_id_1 = 1 AND c.status = 'accepted';
```

**4. Get user's skills:**
```sql
SELECT s.skill_name, us.proficiency_level, us.endorsed_count
FROM user_skills us
JOIN skills s ON us.skill_id = s.skill_id
WHERE us.user_id = 1
ORDER BY us.endorsed_count DESC;
```

---

## Customizing the Diagram

### Layout Tips:

1. **Group Related Tables**
   - Place user-related tables together (users, user_skills, education)
   - Group content tables (posts, comments, likes)
   - Separate system tables (companies, skills)

2. **Minimize Line Crossings**
   - Arrange tables to reduce relationship line overlaps
   - Put junction tables between related entities

3. **Use Colors** (if available)
   - Core entities: Blue
   - Junction tables: Green
   - Lookup tables: Yellow

### Suggested Layout:

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  [users] ──→ [posts] ──→ [comments]                │
│     │           │                                   │
│     │           └──→ [likes]                        │
│     │                                               │
│     ├──→ [work_experience] ──→ [companies]         │
│     │                                               │
│     ├──→ [education]                               │
│     │                                               │
│     ├──→ [user_skills] ──→ [skills]                │
│     │                                               │
│     ├──→ [connections] (self-ref)                  │
│     │                                               │
│     └──→ [messages] (self-ref)                     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Troubleshooting

### Issue: Import Fails

**Solution 1**: Check SQL syntax
- Ensure no syntax errors in SQL file
- Try importing one table at a time

**Solution 2**: Use compatible SQL dialect
- The schema uses standard MySQL syntax
- Some tools prefer PostgreSQL or SQLite syntax

**Solution 3**: Manual creation
- Create tables manually if import doesn't work
- Copy column definitions from SQL file

---

### Issue: Relationships Not Showing

**Solution**:
- Ensure foreign keys are properly defined
- Check that referenced tables exist first
- Manually create relationships by dragging

---

### Issue: Sample Data Not Imported

**Solution**:
- Some ERD tools only import schema, not data
- That's okay - the ERD shows structure, not data
- Use a database client (MySQL Workbench, DBeaver) to see data

---

## Alternative ERD Tools

If https://erd.dbdesigner.net/ doesn't work, try:

1. **dbdiagram.io**
   - Code-based (DBML syntax)
   - Clean, modern interface
   - Free tier available

2. **MySQL Workbench**
   - Desktop application
   - Full database management
   - Excellent ERD features

3. **DBeaver**
   - Universal database tool
   - ERD diagram generation
   - Free and open-source

4. **Lucidchart**
   - Professional diagramming
   - Collaboration features
   - Free for basic use

5. **draw.io (diagrams.net)**
   - Free, no registration
   - Manual diagram creation
   - Export to many formats

---

## Learning Exercises

### Exercise 1: Analyze Relationships
- Identify all 1:N relationships
- Find the M:N relationships
- Understand why junction tables are needed

### Exercise 2: Add New Feature
- Add a "Groups" table for professional communities
- Create relationships to users
- Add sample data

### Exercise 3: Query Practice
- Write query to find mutual connections
- Get user's full profile (all related data)
- Find most popular posts

### Exercise 4: Optimization
- Identify which columns need indexes
- Suggest partitioning strategies
- Consider denormalization opportunities

---

## Next Steps

1. ✅ Import the schema into ERD tool
2. ✅ Study the relationships visually
3. ✅ Run sample queries
4. ✅ Modify the schema (add tables/columns)
5. ✅ Export the diagram for documentation
6. ✅ Share with team for review

---

## Resources

- **SQL File**: `03_LinkedIn_Schema.sql`
- **Documentation**: `02_LinkedIn_Data_Model_Explanation.md`
- **General Guide**: `01_Complete_Data_Modelling_Guide.md`

---

## Questions to Consider

1. Why is `connections` table self-referencing?
2. Why do we need a junction table for user-skills?
3. What's the purpose of `is_deleted` flag?
4. How does the schema prevent duplicate connections?
5. Why use surrogate keys instead of natural keys?

**Answers are in the documentation files!**

---

## Conclusion

This LinkedIn schema demonstrates:
- ✅ Proper normalization (3NF)
- ✅ Various relationship types
- ✅ Self-referencing relationships
- ✅ Junction tables for M:N
- ✅ Soft deletes
- ✅ Audit trails
- ✅ Referential integrity

**Happy Modeling! 🎨**
