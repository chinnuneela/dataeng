# Data Modelling Learning Resources

## 📚 Overview

This folder contains comprehensive resources for learning **Data Modelling** from basics to practical implementation. All materials are designed for hands-on learning with real-world examples.

---

## 📖 Contents

### 1. Complete Data Modelling Guide
**File**: `01_Complete_Data_Modelling_Guide.md`

**What's Inside**:
- ✅ Introduction to data modelling concepts
- ✅ Types of data models (Conceptual, Logical, Physical)
- ✅ Entities, attributes, and relationships
- ✅ Normalization (1NF through 5NF) with examples
- ✅ Keys and constraints explained
- ✅ Step-by-step modelling process
- ✅ Best practices and naming conventions
- ✅ Common design patterns
- ✅ Tools and technologies

**Who Should Read**: Everyone - start here if you're new to data modelling

**Time to Complete**: 2-3 hours

---

### 2. LinkedIn Data Model Explanation
**File**: `02_LinkedIn_Data_Model_Explanation.md`

**What's Inside**:
- ✅ Detailed breakdown of LinkedIn-like platform
- ✅ 11 core entities explained
- ✅ Relationship diagrams
- ✅ Business rules for each entity
- ✅ Sample queries
- ✅ Design decisions explained
- ✅ Scalability considerations

**Who Should Read**: After reading the complete guide, use this as a practical example

**Time to Complete**: 1-2 hours

---

### 3. LinkedIn SQL Schema
**File**: `03_LinkedIn_Schema.sql`

**What's Inside**:
- ✅ Executable SQL DDL statements
- ✅ All 11 tables with proper constraints
- ✅ Foreign key relationships
- ✅ Indexes for performance
- ✅ Sample data (5 users, posts, companies, etc.)
- ✅ Test queries (commented)

**Who Should Use**: Import into ERD tool or database

**Compatible With**: 
- https://erd.dbdesigner.net/
- MySQL Workbench
- DBeaver
- Any MySQL-compatible database

---

### 4. ERD Tool Usage Guide
**File**: `04_ERD_Tool_Usage_Guide.md`

**What's Inside**:
- ✅ Step-by-step import instructions
- ✅ How to visualize relationships
- ✅ Layout tips and best practices
- ✅ Troubleshooting common issues
- ✅ Alternative tools
- ✅ Learning exercises

**Who Should Read**: Before importing the SQL schema

**Time to Complete**: 30 minutes

---

## 🎯 Learning Path

### For Beginners:

```
1. Read: 01_Complete_Data_Modelling_Guide.md
   ↓
2. Read: 02_LinkedIn_Data_Model_Explanation.md
   ↓
3. Read: 04_ERD_Tool_Usage_Guide.md
   ↓
4. Import: 03_LinkedIn_Schema.sql into ERD tool
   ↓
5. Visualize and explore the relationships
   ↓
6. Practice: Modify the schema, add new features
```

### For Intermediate Users:

```
1. Review: 02_LinkedIn_Data_Model_Explanation.md
   ↓
2. Import: 03_LinkedIn_Schema.sql
   ↓
3. Analyze: Relationships and design decisions
   ↓
4. Extend: Add new features (groups, notifications, etc.)
   ↓
5. Optimize: Add indexes, consider partitioning
```

### For Advanced Users:

```
1. Study: Design patterns in the schema
   ↓
2. Critique: Find potential improvements
   ↓
3. Scale: Design for millions of users
   ↓
4. Compare: With actual LinkedIn architecture
   ↓
5. Teach: Share knowledge with team
```

---

## 🚀 Quick Start

### Option 1: Visual Learning (Recommended)

1. Open https://erd.dbdesigner.net/
2. Click "Import" → "From SQL"
3. Copy entire content from `03_LinkedIn_Schema.sql`
4. Paste and import
5. Click "Auto Arrange"
6. Explore the visual diagram!

### Option 2: Database Practice

1. Install MySQL or PostgreSQL
2. Create a new database: `CREATE DATABASE linkedin_demo;`
3. Run the SQL file: `mysql linkedin_demo < 03_LinkedIn_Schema.sql`
4. Query the data and explore relationships

### Option 3: Reading First

1. Start with `01_Complete_Data_Modelling_Guide.md`
2. Take notes on key concepts
3. Move to LinkedIn example
4. Then try the practical exercises

---

## 📊 LinkedIn Data Model Overview

### Entities (11 Tables):

| Table | Purpose | Key Relationships |
|-------|---------|-------------------|
| **users** | User profiles | → posts, comments, likes, messages |
| **companies** | Organizations | ← work_experience |
| **posts** | User content | ← comments, likes |
| **comments** | Post comments | → posts, users |
| **likes** | Post reactions | → posts, users |
| **connections** | User network | Self-referencing (users ↔ users) |
| **work_experience** | Job history | → users, companies |
| **education** | Academic background | → users |
| **skills** | Skill master list | ← user_skills |
| **user_skills** | User-skill mapping | → users, skills (M:N junction) |
| **messages** | Direct messaging | Self-referencing (users ↔ users) |

### Relationship Types Demonstrated:

- ✅ **One-to-Many (1:N)**: users → posts
- ✅ **Many-to-Many (M:N)**: users ↔ skills (via user_skills)
- ✅ **Self-Referencing**: connections, messages
- ✅ **Optional**: work_experience → companies (can be NULL)
- ✅ **Mandatory**: posts → users (cannot be NULL)

---

## 💡 Key Concepts Covered

### Normalization:
- First Normal Form (1NF): Atomic values
- Second Normal Form (2NF): No partial dependencies
- Third Normal Form (3NF): No transitive dependencies
- When to denormalize for performance

### Design Patterns:
- **Soft Deletes**: `is_deleted` flag instead of DELETE
- **Audit Trail**: `created_at`, `updated_at` timestamps
- **Junction Tables**: For many-to-many relationships
- **Self-Referencing**: For hierarchical/network data
- **Surrogate Keys**: Auto-increment IDs

### Best Practices:
- Consistent naming conventions
- Proper indexing strategies
- Referential integrity with foreign keys
- Appropriate data types
- Documentation and comments

---

## 🛠️ Tools You'll Need

### Required:
- **Web Browser**: For ERD tool (https://erd.dbdesigner.net/)
- **Text Editor**: To view .md and .sql files

### Optional (for deeper practice):
- **MySQL/PostgreSQL**: To run the schema
- **MySQL Workbench**: Visual database design
- **DBeaver**: Universal database tool
- **dbdiagram.io**: Alternative ERD tool

---

## 📝 Exercises

### Exercise 1: Understand Existing Schema
- [ ] Import SQL into ERD tool
- [ ] Identify all primary keys
- [ ] Trace all foreign key relationships
- [ ] Find the junction tables
- [ ] Understand self-referencing tables

### Exercise 2: Extend the Model
- [ ] Add a "Groups" table for communities
- [ ] Add "Notifications" for user alerts
- [ ] Add "Job_Postings" for career opportunities
- [ ] Add "Endorsements" for skill validation
- [ ] Create appropriate relationships

### Exercise 3: Write Queries
- [ ] Get user's full profile (all related data)
- [ ] Find mutual connections between two users
- [ ] Get most popular posts (by likes)
- [ ] Find users with specific skills
- [ ] Get user's complete work history

### Exercise 4: Optimize
- [ ] Identify columns that need indexes
- [ ] Suggest partitioning strategies for large tables
- [ ] Find opportunities for denormalization
- [ ] Design caching strategy

### Exercise 5: Real-World Scenarios
- [ ] How to handle user deactivation?
- [ ] How to implement privacy settings?
- [ ] How to track profile views?
- [ ] How to recommend connections?
- [ ] How to handle spam/abuse reports?

---

## 🎓 Learning Outcomes

After completing these materials, you will:

- ✅ Understand data modelling fundamentals
- ✅ Know when to use different relationship types
- ✅ Apply normalization principles
- ✅ Design scalable database schemas
- ✅ Use ERD tools effectively
- ✅ Write efficient SQL queries
- ✅ Make informed design decisions
- ✅ Document data models professionally

---

## 📚 Additional Resources

### Books:
- "Database Design for Mere Mortals" by Michael J. Hernandez
- "SQL Performance Explained" by Markus Winand
- "The Data Warehouse Toolkit" by Ralph Kimball

### Online:
- SQL Style Guide: https://www.sqlstyle.guide/
- Database Normalization: https://www.guru99.com/database-normalization.html
- ERD Tutorial: https://www.lucidchart.com/pages/er-diagrams

### Practice:
- LeetCode Database Problems
- HackerRank SQL Challenges
- Mode Analytics SQL Tutorial

---

## 🤝 Contributing

Found an issue or want to improve the examples?
- Review the schema and suggest improvements
- Add more sample data
- Create additional exercises
- Share your extended models

---

## ❓ Common Questions

### Q: Why use surrogate keys instead of natural keys?
**A**: Surrogate keys (auto-increment IDs) are:
- Immutable (don't change)
- Simple (single column)
- Efficient (integer indexing)
- Flexible (natural keys can change)

### Q: When should I denormalize?
**A**: Consider denormalization when:
- Read performance is critical
- Joins are too expensive
- Data doesn't change often
- You have a caching strategy

### Q: How do I handle soft deletes?
**A**: Use `is_deleted` boolean flag:
- Preserves data for analytics
- Allows restoration
- Maintains referential integrity
- Filter with `WHERE is_deleted = FALSE`

### Q: What's the difference between DELETE CASCADE and SET NULL?
**A**: 
- **CASCADE**: Deletes related records (e.g., delete user → delete all their posts)
- **SET NULL**: Sets foreign key to NULL (e.g., delete company → set company_id to NULL in work_experience)

---

## 🎯 Next Steps

1. **Complete the learning path** for your skill level
2. **Import and visualize** the LinkedIn schema
3. **Practice queries** on the sample data
4. **Extend the model** with new features
5. **Apply to real projects** at work or personal projects
6. **Share knowledge** with your team

---

## 📞 Need Help?

- Review the documentation files
- Check the ERD tool usage guide
- Try the sample queries
- Experiment with modifications
- Learn by doing!

---

**Happy Data Modelling! 🎨📊**

Remember: Good data modelling is the foundation of great applications!
