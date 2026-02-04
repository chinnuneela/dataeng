# How to Use the DBML Schema File

## What is DBML?

**DBML (Database Markup Language)** is a simple, readable language designed to define database structures. It's much cleaner and easier to read than SQL DDL.

---

## Quick Start with dbdiagram.io

### Step 1: Open dbdiagram.io
1. Go to: **https://dbdiagram.io/**
2. You'll see a code editor on the left and diagram preview on the right

### Step 2: Import the Schema
1. **Option A - Copy/Paste:**
   - Open `06_LinkedIn_DBML_Schema.dbml`
   - Copy all content
   - Paste into the dbdiagram.io editor
   - The diagram updates automatically!

2. **Option B - Import File:**
   - Click "Import" button
   - Select "From file"
   - Upload `06_LinkedIn_DBML_Schema.dbml`

### Step 3: Explore the Diagram
- The visual ERD appears on the right
- Relationships are shown as connecting lines
- Hover over lines to see relationship details
- Zoom in/out with mouse wheel
- Drag tables to rearrange

### Step 4: Customize (Optional)
- Edit the DBML code on the left
- Add/remove tables or columns
- Change relationships
- Diagram updates in real-time!

### Step 5: Export
- Click "Export" button
- Choose format:
  - **PDF** - For documentation
  - **PNG** - For presentations
  - **SQL** - Generate SQL DDL
  - **DBML** - Save your changes

---

## DBML Syntax Explained

### Basic Table Definition
```dbml
Table users {
  user_id int [pk, increment]     // Primary key, auto-increment
  email varchar(100) [unique]     // Unique constraint
  name varchar(50) [not null]     // Not null constraint
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
}
```

### Relationship Syntax

**One-to-Many (>):**
```dbml
Table posts {
  user_id int [ref: > users.user_id]  // Many posts -> One user
}
```

**Many-to-One (<):**
```dbml
Table users {
  company_id int [ref: < companies.company_id]  // Many users <- One company
}
```

**One-to-One (-):**
```dbml
Table user_profiles {
  user_id int [ref: - users.user_id]  // One profile - One user
}
```

**Many-to-Many (<>):**
```dbml
// Requires junction table
Table user_skills {
  user_id int [ref: > users.user_id]
  skill_id int [ref: > skills.skill_id]
}
```

### Inline vs Reference Relationships

**Inline (in column definition):**
```dbml
Table posts {
  user_id int [ref: > users.user_id]
}
```

**Reference (separate block):**
```dbml
Ref: posts.user_id > users.user_id
```

### Indexes
```dbml
Table users {
  email varchar(100)
  
  Indexes {
    email [unique]
    (first_name, last_name)  // Composite index
  }
}
```

### Notes and Comments
```dbml
Table users {
  status varchar(20) [note: 'active, inactive, suspended']
  
  Note: 'This table stores user information'
}

// Single line comment
/* Multi-line
   comment */
```

---

## LinkedIn Schema Overview

### Core Tables (11):
1. **users** - User profiles
2. **companies** - Organizations
3. **posts** - User content
4. **comments** - Post comments
5. **likes** - Post reactions
6. **connections** - User network
7. **messages** - Direct messaging
8. **work_experience** - Job history
9. **education** - Academic background
10. **skills** - Skill master list
11. **user_skills** - User-skill mapping

### Extended Tables (10):
12. **groups** - Professional communities
13. **group_members** - Group membership
14. **job_postings** - Career opportunities
15. **job_applications** - Job applications
16. **notifications** - User alerts
17. **endorsements** - Skill endorsements
18. **recommendations** - Written testimonials
19. **search_history** - Search tracking
20. **profile_views** - Profile analytics
21. **shares** - Post sharing

---

## Key Features in This Schema

### ✅ Proper Normalization
- All tables in 3NF
- No redundant data
- Proper foreign keys

### ✅ Comprehensive Relationships
- **One-to-Many**: users → posts
- **Many-to-Many**: users ↔ skills
- **Self-Referencing**: connections, messages

### ✅ Best Practices
- Surrogate keys (auto-increment)
- Soft deletes (`is_deleted`)
- Audit trails (`created_at`, `updated_at`)
- Proper indexing

### ✅ Real-World Features
- Job postings and applications
- Groups and communities
- Endorsements and recommendations
- Search history
- Profile views analytics
- Notifications system

---

## Customization Ideas

### Add New Table:
```dbml
Table events {
  event_id int [pk, increment]
  created_by int [ref: > users.user_id]
  event_name varchar(200)
  event_date timestamp
  location varchar(100)
}
```

### Add New Column:
```dbml
Table users {
  // ... existing columns ...
  phone_number varchar(20)
  country_code varchar(5)
}
```

### Add New Relationship:
```dbml
Table event_attendees {
  attendee_id int [pk, increment]
  event_id int [ref: > events.event_id]
  user_id int [ref: > users.user_id]
  rsvp_status varchar(20)
}
```

---

## Comparison: DBML vs SQL

### DBML (Clean & Readable):
```dbml
Table users {
  user_id int [pk, increment]
  email varchar(100) [unique, not null]
}

Table posts {
  post_id int [pk, increment]
  user_id int [ref: > users.user_id]
}
```

### SQL (Verbose):
```sql
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE posts (
  post_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

**DBML is much cleaner for visualization!**

---

## Export Options

### 1. Export to SQL
- Click "Export" → "MySQL"
- Get complete SQL DDL
- Ready to execute in database

### 2. Export to PDF
- Click "Export" → "PDF"
- Professional documentation
- Share with team

### 3. Export to PNG
- Click "Export" → "PNG"
- High-resolution image
- Use in presentations

### 4. Share Online
- Click "Share" button
- Get shareable link
- Collaborate with team

---

## Advanced Features

### Table Groups (Visual Organization):
```dbml
TableGroup user_related {
  users
  work_experience
  education
  user_skills
}

TableGroup content_related {
  posts
  comments
  likes
  shares
}
```

### Enums (Predefined Values):
```dbml
enum employment_type {
  full_time
  part_time
  contract
  freelance
  internship
}

Table work_experience {
  employment_type employment_type
}
```

### Colors (Visual Distinction):
```dbml
Table users [headercolor: #3498db] {
  user_id int [pk]
}

Table posts [headercolor: #e74c3c] {
  post_id int [pk]
}
```

---

## Troubleshooting

### Issue: Syntax Error
**Solution:** Check for:
- Missing brackets `[]` or braces `{}`
- Incorrect relationship syntax
- Typos in table/column names

### Issue: Relationship Not Showing
**Solution:**
- Ensure both tables exist
- Check column names match exactly
- Use correct relationship operator (>, <, -)

### Issue: Diagram Too Crowded
**Solution:**
- Use "Auto Arrange" button
- Manually drag tables
- Hide less important tables temporarily

---

## Learning Exercises

### Exercise 1: Explore Existing Schema
- [ ] Identify all primary keys
- [ ] Find all foreign key relationships
- [ ] Locate junction tables
- [ ] Understand self-referencing tables

### Exercise 2: Add New Features
- [ ] Add "Events" table
- [ ] Add "Polls" feature
- [ ] Add "Certifications" to user profile
- [ ] Add "Company Reviews"

### Exercise 3: Modify Relationships
- [ ] Change a 1:N to M:N relationship
- [ ] Add a new self-referencing table
- [ ] Create a new junction table

### Exercise 4: Export and Share
- [ ] Export to SQL
- [ ] Export to PDF
- [ ] Share link with team
- [ ] Import into MySQL Workbench

---

## Resources

### Official Documentation:
- DBML Docs: https://dbml.dbdiagram.io/docs/
- dbdiagram.io Guide: https://dbdiagram.io/docs

### Alternative Tools:
- **dbdocs.io** - Generate documentation from DBML
- **SQL Designer** - Visual database design
- **QuickDBD** - Quick database diagrams

---

## Comparison with Other Tools

| Feature | dbdiagram.io | erd.dbdesigner.net | MySQL Workbench |
|---------|--------------|-------------------|-----------------|
| **Format** | DBML | SQL | Visual/SQL |
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Collaboration** | ✅ Share links | ❌ | ❌ |
| **Export Options** | SQL, PDF, PNG | SQL | SQL, PNG, PDF |
| **Real-time Preview** | ✅ | ✅ | ❌ |
| **Code-based** | ✅ | ❌ | ❌ |
| **Free Tier** | ✅ | ✅ | ✅ |

---

## Next Steps

1. ✅ Open https://dbdiagram.io/
2. ✅ Copy content from `06_LinkedIn_DBML_Schema.dbml`
3. ✅ Paste into editor
4. ✅ Explore the visual diagram
5. ✅ Customize and extend
6. ✅ Export for documentation
7. ✅ Share with team

---

## Pro Tips

💡 **Tip 1:** Use comments to document business rules
```dbml
Table users {
  status varchar(20) [note: 'active: can login, inactive: suspended, deleted: soft delete']
}
```

💡 **Tip 2:** Group related tables visually
- Drag tables close to related tables
- Use consistent naming patterns

💡 **Tip 3:** Use indexes strategically
```dbml
Indexes {
  email [unique]  // Unique constraint + index
  (first_name, last_name)  // Composite index for searches
}
```

💡 **Tip 4:** Document relationships
```dbml
Ref: posts.user_id > users.user_id [note: 'One user creates many posts']
```

💡 **Tip 5:** Export regularly
- Save your work as DBML file
- Version control with Git
- Export to PDF for documentation

---

**Happy Diagramming! 🎨**

The DBML format makes database design visual, collaborative, and fun!
