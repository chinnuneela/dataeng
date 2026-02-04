# Step 3: Relationships Explained - Facebook

## Key Facebook Relationships

### 1. Users ↔ Users (Friendships) - BIDIRECTIONAL

**Type:** Many-to-Many (M:N) Self-Referencing - MUTUAL

**Implementation:**
```sql
friendships.user_id_1 → users.user_id
friendships.user_id_2 → users.user_id
```

**Key Difference from Twitter:**
- Facebook: **Bidirectional** (mutual friendship)
- Twitter: **Unidirectional** (one-way follow)

**Business Rules:**
- Requires friend request acceptance
- Both users are friends with each other
- Cannot friend yourself
- No duplicate friendships

**SQL Constraint:**
```sql
UNIQUE (user_id_1, user_id_2)
CHECK (user_id_1 != user_id_2)
CHECK (user_id_1 < user_id_2)  -- Prevent (1,2) and (2,1)
```

---

### 2. Friend Requests Flow

**Type:** One-to-Many with Status

**Flow:**
1. User A sends request to User B
2. Request status = 'pending'
3. User B accepts → Create friendship record
4. User B rejects → Update status to 'rejected'

**Implementation:**
```sql
friend_requests.sender_id → users.user_id
friend_requests.receiver_id → users.user_id
```

---

### 3. Users → Posts (1:N)

**Type:** One-to-Many

**Description:** Users create posts on their timeline

**Implementation:**
```sql
posts.user_id → users.user_id
```

**Cardinality:** One user → Many posts

---

### 4. Groups → Posts (1:N)

**Type:** One-to-Many

**Description:** Posts can be in groups

**Implementation:**
```sql
posts.group_id → groups.group_id
```

**Note:** Post belongs to user OR group OR page (not multiple)

---

### 5. Users ↔ Posts (Reactions) - M:N

**Type:** Many-to-Many

**Description:** Users react to posts with 6 reaction types

**Implementation:**
```sql
reactions.user_id → users.user_id
reactions.post_id → posts.post_id
```

**Unique Feature:** 6 reaction types (Like, Love, Haha, Wow, Sad, Angry)

**Business Rules:**
- One reaction per user per post
- Can change reaction type
- Removing reaction deletes record

---

### 6. Posts → Comments (1:N)

**Type:** One-to-Many

**Description:** Posts have comments

**Implementation:**
```sql
comments.post_id → posts.post_id
```

---

### 7. Comments → Comments (Self-Referencing)

**Type:** One-to-Many Self-Referencing

**Description:** Comments can have replies (nested)

**Implementation:**
```sql
comments.parent_comment_id → comments.comment_id
```

**Creates:** Threaded discussions

---

### 8. Users ↔ Groups (M:N with Roles)

**Type:** Many-to-Many with Attributes

**Implementation:**
```sql
group_members.user_id → users.user_id
group_members.group_id → groups.group_id
```

**Special Attribute:** role (admin, moderator, member)

**Business Rules:**
- Admins can manage group
- Moderators can moderate content
- Members can post and comment

---

### 9. Users ↔ Pages (M:N)

**Type:** Many-to-Many

**Description:** Users follow pages (not friend)

**Implementation:**
```sql
page_followers.user_id → users.user_id
page_followers.page_id → pages.page_id
```

**Key Difference:** Follow vs Friend

---

### 10. Users ↔ Events (M:N with RSVP)

**Type:** Many-to-Many with Status

**Implementation:**
```sql
event_attendees.user_id → users.user_id
event_attendees.event_id → events.event_id
```

**RSVP Status:** going, interested, not_going

---

### 11. Photos ↔ Users (Photo Tags) - M:N

**Type:** Many-to-Many

**Description:** Multiple users can be tagged in one photo

**Implementation:**
```sql
photo_tags.photo_id → photos.photo_id
photo_tags.user_id → users.user_id
```

**Use Case:** Tag friends in photos

---

### 12. Users ↔ Conversations (M:N)

**Type:** Many-to-Many

**Description:** Users participate in conversations (1-on-1 or group)

**Implementation:**
```sql
conversation_participants.user_id → users.user_id
conversation_participants.conversation_id → conversations.conversation_id
```

**Supports:** Group chats

---

## Relationship Summary Table

| Relationship | Type | Bidirectional? | Junction Table |
|-------------|------|----------------|----------------|
| Users ↔ Users (Friends) | M:N | ✅ Yes | friendships |
| Users → Posts | 1:N | ❌ No | - |
| Users ↔ Posts (Reactions) | M:N | ❌ No | reactions |
| Posts → Comments | 1:N | ❌ No | - |
| Comments → Comments | 1:N | ❌ No | - |
| Users ↔ Groups | M:N | ❌ No | group_members |
| Users ↔ Pages | M:N | ❌ No | page_followers |
| Users ↔ Events | M:N | ❌ No | event_attendees |
| Photos ↔ Users | M:N | ❌ No | photo_tags |
| Users ↔ Conversations | M:N | ❌ No | conversation_participants |

---

## Key Design Decisions

### 1. Bidirectional Friendships
- Requires friend request acceptance
- Both users must agree
- Different from Twitter's follow model

### 2. Multiple Reaction Types
- 6 reaction types vs simple like
- Richer emotional expression
- One reaction per user per post

### 3. Nested Comments
- Self-referencing for threading
- Supports deep discussions
- parent_comment_id enables nesting

### 4. Group Roles
- Admin, Moderator, Member
- Different permission levels
- Stored in junction table

### 5. Polymorphic Posts
- Posts can be on user timeline, group, or page
- Nullable foreign keys (group_id, page_id)
- Flexible content placement

---

## Next Steps

1. ✅ Step 1: Problem diagnosis
2. ✅ Step 2: Entity identification
3. ✅ Step 3: Establish relationships (CURRENT)
4. ✅ Step 4: Create data model diagram
5. ⏭️ Step 5: Write SQL queries
