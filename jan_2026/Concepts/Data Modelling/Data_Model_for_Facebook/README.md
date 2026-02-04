# Facebook Data Model - Complete Guide

## 📚 Overview

This folder contains a **complete, step-by-step guide** to designing a data model for Facebook. Each step builds upon the previous one, from problem analysis to working SQL queries.

---

## 📖 Contents

### Step 1: Problem Statement Analysis
**File:** `01_Problem_Statement_Analysis.md`

**Covers:**
- Facebook's core features
- Requirements analysis (10 categories)
- Scope definition
- Key challenges (bidirectional friendships, privacy, reactions)
- Business rules
- Unique Facebook features vs Twitter

**Time:** 30 minutes

---

### Step 2: Entity Identification
**File:** `02_Entity_Identification.md`

**Covers:**
- **18+ Entities** explained
- Detailed attributes for each
- Business rules per entity

**Entities:**
1. users - User profiles
2. friendships - Bidirectional connections
3. friend_requests - Pending requests
4. posts - Content (timeline, group, page)
5. reactions - 6 reaction types
6. comments - Nested discussions
7. shares - Post sharing
8. groups - Communities
9. group_members - Membership with roles
10. pages - Business pages
11. page_followers - Page followers
12. events - Social events
13. event_attendees - RSVPs
14. photo_albums - Photo collections
15. photos - Images
16. photo_tags - People in photos
17. conversations - Message threads
18. conversation_participants - Chat members
19. messages - Individual messages
20. notifications - Activity alerts

**Time:** 1-2 hours

---

### Step 3: Relationships Explained
**File:** `03_Relationships_Explained.md`

**Covers:**
- All relationships explained
- Bidirectional friendships (key difference from Twitter)
- Friend request flow
- Multiple reaction types
- Nested comments
- Group roles
- Photo tagging

**Time:** 1 hour

---

### Step 4: Data Model Diagram
**File:** `04_Facebook_Data_Model.dbml`

**Contains:**
- Complete DBML schema
- 18+ tables with full definitions
- All relationships
- Indexes and constraints
- Comprehensive documentation

**How to Use:**
1. Go to https://dbdiagram.io/
2. Copy entire file content
3. Paste into editor
4. See instant visual ERD!

**Time:** 15 minutes

---

### Step 5: SQL Queries and Use Cases
**File:** `05_SQL_Queries_and_Use_Cases.md`

**Contains:**
- **40+ SQL Queries**
- 10 Query Categories:
  1. User & Friendship queries
  2. News Feed queries
  3. Reaction queries
  4. Comment queries
  5. Group queries
  6. Page queries
  7. Event queries
  8. Photo queries
  9. Messaging queries
  10. Notification queries

**Time:** 2-3 hours

---

## 🎯 Learning Path

### For Beginners:
```
1. Read: 01_Problem_Statement_Analysis.md
2. Study: 02_Entity_Identification.md
3. Understand: 03_Relationships_Explained.md
4. Visualize: Import 04_Facebook_Data_Model.dbml
5. Practice: Try queries from Step 5
```

### Quick Start:
```
1. Open: https://dbdiagram.io/
2. Copy: 04_Facebook_Data_Model.dbml
3. Paste and visualize
4. Explore relationships
```

---

## 🔑 Key Facebook Features

### 1. Bidirectional Friendships
- **Unlike Twitter:** Mutual friendship required
- Friend request → Accept → Friendship created
- Both users are friends with each other

### 2. Multiple Reaction Types
- 👍 Like
- ❤️ Love
- 😂 Haha
- 😮 Wow
- 😢 Sad
- 😠 Angry

### 3. Nested Comments
- Comments can have replies
- Self-referencing relationship
- Threaded discussions

### 4. Groups with Roles
- Admin: Full control
- Moderator: Content moderation
- Member: Regular participation

### 5. Pages (Business Presence)
- Followed (not friended)
- Business categories
- Multiple admins

### 6. Events with RSVPs
- Going
- Interested
- Not Going

### 7. Photo Tagging
- Tag multiple people in photos
- "Photos of You" feature

### 8. Group Chats
- One-on-one conversations
- Group conversations
- Multiple participants

### 9. Privacy Levels
- Public
- Friends
- Custom

### 10. Rich Notifications
- Friend requests
- Post reactions
- Comments
- Event invites
- Birthday reminders

---

## 📊 Data Model Statistics

- **18+ Tables**
- **10+ Junction Tables**
- **Bidirectional Relationships**
- **40+ SQL Queries**
- **100KB+ Documentation**

---

## 💡 Unique Design Decisions

### 1. Bidirectional Friendships
```sql
-- Prevent (1,2) and (2,1) duplicates
CHECK (user_id_1 < user_id_2)
```

### 2. Friend Request Flow
```
Send Request → Pending → Accept/Reject
If Accept → Create Friendship
```

### 3. Polymorphic Posts
```sql
-- Posts can be on:
user_id (timeline)
group_id (group)
page_id (page)
```

### 4. Reaction Types (ENUM)
```sql
reaction_type ENUM('like', 'love', 'haha', 'wow', 'sad', 'angry')
```

### 5. Group Roles
```sql
role ENUM('admin', 'moderator', 'member')
```

---

## 🚀 Quick Queries

### Get Friends:
```sql
SELECT u.* FROM users u
JOIN friendships f ON (u.user_id = f.user_id_1 OR u.user_id = f.user_id_2)
WHERE (f.user_id_1 = 1 OR f.user_id_2 = 1) AND u.user_id != 1;
```

### Get News Feed:
```sql
SELECT p.* FROM posts p
WHERE p.user_id IN (SELECT friend_id FROM my_friends)
ORDER BY p.created_at DESC;
```

### Get Reactions by Type:
```sql
SELECT reaction_type, COUNT(*) 
FROM reactions 
WHERE post_id = 123 
GROUP BY reaction_type;
```

---

## 🎓 Learning Outcomes

After completing this guide:
- ✅ Understand bidirectional relationships
- ✅ Model complex social features
- ✅ Handle privacy settings
- ✅ Design for rich engagement
- ✅ Write advanced SQL queries
- ✅ Optimize for scale

---

## 📝 Exercises

### Exercise 1: Extend the Model
- [ ] Add Facebook Stories (24-hour content)
- [ ] Add Marketplace
- [ ] Add Facebook Dating
- [ ] Add Polls

### Exercise 2: Write Queries
- [ ] Friend suggestions algorithm
- [ ] Trending posts
- [ ] Mutual friends count
- [ ] Event recommendations

### Exercise 3: Optimize
- [ ] Add indexes for common queries
- [ ] Design caching strategy
- [ ] Plan partitioning
- [ ] Denormalize for performance

---

## 🔍 Comparison: Facebook vs Twitter

| Feature | Facebook | Twitter |
|---------|----------|---------|
| **Connections** | Bidirectional (friends) | Unidirectional (follow) |
| **Reactions** | 6 types | 1 type (like) |
| **Comments** | Nested (threaded) | Flat (replies) |
| **Groups** | Yes (with roles) | No (Communities) |
| **Pages** | Yes (business) | No (just accounts) |
| **Events** | Yes (with RSVPs) | No |
| **Privacy** | Granular (public/friends/custom) | Simple (public/protected) |
| **Messaging** | Group chats | DMs only |

---

## 🛠️ Tools Needed

- **Web Browser:** For dbdiagram.io
- **Text Editor:** To view files
- **MySQL/PostgreSQL:** (Optional) For practice

---

## 📚 Additional Resources

- Facebook Engineering Blog
- System Design Primer
- Database Design Books
- SQL Performance Tuning

---

## ❓ FAQ

**Q: Why bidirectional friendships?**
A: Facebook is about real-world relationships (mutual). Twitter is about information flow (one-way).

**Q: Why 6 reaction types?**
A: Richer emotional expression. Simple "like" doesn't capture all responses.

**Q: Why nested comments?**
A: Enables threaded discussions and deeper conversations.

**Q: Why separate groups and pages?**
A: Groups = communities (peer-to-peer). Pages = brands (one-to-many).

---

## 🎯 Next Steps

1. ✅ Read all 5 steps
2. ✅ Visualize the data model
3. ✅ Practice SQL queries
4. ✅ Extend with new features
5. ✅ Build a Facebook clone!

---

**Happy Learning! 🚀**

This Facebook data model demonstrates professional social network design from requirements to implementation!
