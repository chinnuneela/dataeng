# Step 5: SQL Queries and Use Cases - Facebook

## Facebook SQL Queries

### 1. USER & FRIENDSHIP QUERIES

#### Query 1.1: Get User Profile
```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.profile_picture_url,
    u.cover_photo_url,
    u.bio,
    u.location,
    u.relationship_status,
    u.friends_count,
    u.created_at
FROM users u
WHERE u.user_id = 1;
```

#### Query 1.2: Get User's Friends
```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.profile_picture_url,
    f.created_at AS friends_since
FROM friendships f
JOIN users u ON (
    CASE 
        WHEN f.user_id_1 = 1 THEN f.user_id_2 = u.user_id
        WHEN f.user_id_2 = 1 THEN f.user_id_1 = u.user_id
    END
)
WHERE f.user_id_1 = 1 OR f.user_id_2 = 1
ORDER BY f.created_at DESC;
```

**Use Case:** Friends list page

#### Query 1.3: Get Pending Friend Requests
```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.profile_picture_url,
    fr.requested_at
FROM friend_requests fr
JOIN users u ON fr.sender_id = u.user_id
WHERE fr.receiver_id = 1
  AND fr.status = 'pending'
ORDER BY fr.requested_at DESC;
```

**Use Case:** Friend requests notification

#### Query 1.4: Find Mutual Friends
```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(*) AS mutual_friends_count
FROM users u
WHERE u.user_id IN (
    -- Friends of user 1
    SELECT CASE 
        WHEN user_id_1 = 1 THEN user_id_2
        ELSE user_id_1
    END
    FROM friendships
    WHERE user_id_1 = 1 OR user_id_2 = 1
)
AND u.user_id IN (
    -- Friends of user 2
    SELECT CASE 
        WHEN user_id_1 = 2 THEN user_id_2
        ELSE user_id_1
    END
    FROM friendships
    WHERE user_id_1 = 2 OR user_id_2 = 2
)
GROUP BY u.user_id;
```

**Use Case:** "X mutual friends" display

#### Query 1.5: Friend Suggestions (Friends of Friends)
```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.profile_picture_url,
    COUNT(DISTINCT f2.user_id_1, f2.user_id_2) AS mutual_friends
FROM users u
JOIN friendships f1 ON (u.user_id = f1.user_id_1 OR u.user_id = f1.user_id_2)
JOIN friendships f2 ON (
    (f1.user_id_1 = f2.user_id_1 OR f1.user_id_1 = f2.user_id_2 OR
     f1.user_id_2 = f2.user_id_1 OR f1.user_id_2 = f2.user_id_2)
)
WHERE u.user_id != 1  -- Not me
  AND u.user_id NOT IN (
    -- Not already friends
    SELECT CASE WHEN user_id_1 = 1 THEN user_id_2 ELSE user_id_1 END
    FROM friendships
    WHERE user_id_1 = 1 OR user_id_2 = 1
  )
GROUP BY u.user_id
ORDER BY mutual_friends DESC
LIMIT 10;
```

**Use Case:** "People you may know"

---

### 2. NEWS FEED QUERIES

#### Query 2.1: Get News Feed (Friends' Posts)
```sql
SELECT 
    p.post_id,
    p.content,
    p.post_type,
    p.created_at,
    p.reactions_count,
    p.comments_count,
    p.shares_count,
    u.user_id,
    u.first_name,
    u.last_name,
    u.profile_picture_url
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE p.user_id IN (
    -- My friends
    SELECT CASE 
        WHEN user_id_1 = 1 THEN user_id_2
        ELSE user_id_1
    END
    FROM friendships
    WHERE user_id_1 = 1 OR user_id_2 = 1
)
  AND p.is_deleted = FALSE
  AND p.privacy_level IN ('public', 'friends')
ORDER BY p.created_at DESC
LIMIT 20;
```

**Use Case:** Main news feed

#### Query 2.2: Get User's Timeline Posts
```sql
SELECT 
    p.post_id,
    p.content,
    p.post_type,
    p.location,
    p.feeling,
    p.created_at,
    p.reactions_count,
    p.comments_count,
    u.first_name,
    u.last_name
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE p.user_id = 1
  AND p.is_deleted = FALSE
  AND p.group_id IS NULL  -- Only timeline posts
  AND p.page_id IS NULL
ORDER BY p.created_at DESC;
```

**Use Case:** User profile timeline

---

### 3. REACTION QUERIES

#### Query 3.1: Get Post Reactions by Type
```sql
SELECT 
    r.reaction_type,
    COUNT(*) AS count,
    GROUP_CONCAT(u.first_name, ' ', u.last_name) AS users
FROM reactions r
JOIN users u ON r.user_id = u.user_id
WHERE r.post_id = 123
GROUP BY r.reaction_type
ORDER BY count DESC;
```

**Use Case:** "10 Likes, 5 Love, 2 Haha" display

#### Query 3.2: Check if User Reacted to Post
```sql
SELECT reaction_type
FROM reactions
WHERE user_id = 1 AND post_id = 123;
```

**Use Case:** Show which reaction button is active

---

### 4. COMMENT QUERIES

#### Query 4.1: Get Post Comments (Top-Level Only)
```sql
SELECT 
    c.comment_id,
    c.content,
    c.created_at,
    c.reactions_count,
    u.user_id,
    u.first_name,
    u.last_name,
    u.profile_picture_url,
    -- Count replies
    (SELECT COUNT(*) FROM comments WHERE parent_comment_id = c.comment_id) AS reply_count
FROM comments c
JOIN users u ON c.user_id = u.user_id
WHERE c.post_id = 123
  AND c.parent_comment_id IS NULL  -- Top-level only
  AND c.is_deleted = FALSE
ORDER BY c.created_at ASC;
```

**Use Case:** Post comments section

#### Query 4.2: Get Comment Replies (Nested)
```sql
SELECT 
    c.comment_id,
    c.content,
    c.created_at,
    u.first_name,
    u.last_name,
    u.profile_picture_url
FROM comments c
JOIN users u ON c.user_id = u.user_id
WHERE c.parent_comment_id = 456
  AND c.is_deleted = FALSE
ORDER BY c.created_at ASC;
```

**Use Case:** "View replies" expansion

---

### 5. GROUP QUERIES

#### Query 5.1: Get User's Groups
```sql
SELECT 
    g.group_id,
    g.name,
    g.description,
    g.privacy_type,
    g.cover_photo_url,
    g.members_count,
    gm.role,
    gm.joined_at
FROM groups g
JOIN group_members gm ON g.group_id = gm.group_id
WHERE gm.user_id = 1
ORDER BY gm.joined_at DESC;
```

**Use Case:** "Your Groups" page

#### Query 5.2: Get Group Posts
```sql
SELECT 
    p.post_id,
    p.content,
    p.created_at,
    p.reactions_count,
    p.comments_count,
    u.first_name,
    u.last_name,
    u.profile_picture_url
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE p.group_id = 10
  AND p.is_deleted = FALSE
ORDER BY p.created_at DESC
LIMIT 20;
```

**Use Case:** Group feed

#### Query 5.3: Get Group Members with Roles
```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.profile_picture_url,
    gm.role,
    gm.joined_at
FROM group_members gm
JOIN users u ON gm.user_id = u.user_id
WHERE gm.group_id = 10
ORDER BY 
    CASE gm.role
        WHEN 'admin' THEN 1
        WHEN 'moderator' THEN 2
        WHEN 'member' THEN 3
    END,
    gm.joined_at;
```

**Use Case:** Group members list

---

### 6. PAGE QUERIES

#### Query 6.1: Get Pages User Follows
```sql
SELECT 
    p.page_id,
    p.name,
    p.category,
    p.profile_picture_url,
    p.followers_count,
    pf.followed_at
FROM pages p
JOIN page_followers pf ON p.page_id = pf.page_id
WHERE pf.user_id = 1
ORDER BY pf.followed_at DESC;
```

**Use Case:** "Pages you follow"

#### Query 6.2: Get Page Posts
```sql
SELECT 
    p.post_id,
    p.content,
    p.post_type,
    p.created_at,
    p.reactions_count,
    p.comments_count,
    pg.name AS page_name,
    pg.profile_picture_url
FROM posts p
JOIN pages pg ON p.page_id = pg.page_id
WHERE p.page_id = 5
  AND p.is_deleted = FALSE
ORDER BY p.created_at DESC;
```

**Use Case:** Page timeline

---

### 7. EVENT QUERIES

#### Query 7.1: Get User's Events
```sql
SELECT 
    e.event_id,
    e.name,
    e.location,
    e.start_time,
    e.end_time,
    e.cover_photo_url,
    ea.rsvp_status
FROM events e
JOIN event_attendees ea ON e.event_id = ea.event_id
WHERE ea.user_id = 1
  AND e.start_time >= NOW()
ORDER BY e.start_time ASC;
```

**Use Case:** "Your Events" page

#### Query 7.2: Get Event Attendees by RSVP Status
```sql
SELECT 
    ea.rsvp_status,
    COUNT(*) AS count
FROM event_attendees ea
WHERE ea.event_id = 20
GROUP BY ea.rsvp_status;
```

**Use Case:** "50 Going, 30 Interested"

---

### 8. PHOTO QUERIES

#### Query 8.1: Get User's Photo Albums
```sql
SELECT 
    pa.album_id,
    pa.name,
    pa.description,
    pa.photos_count,
    pa.created_at,
    -- Get cover photo (first photo)
    (SELECT photo_url FROM photos WHERE album_id = pa.album_id ORDER BY created_at LIMIT 1) AS cover_photo
FROM photo_albums pa
WHERE pa.user_id = 1
ORDER BY pa.created_at DESC;
```

**Use Case:** Photo albums page

#### Query 8.2: Get Photos User is Tagged In
```sql
SELECT 
    ph.photo_id,
    ph.photo_url,
    ph.caption,
    ph.created_at,
    u.first_name AS uploader_name,
    u.last_name
FROM photos ph
JOIN photo_tags pt ON ph.photo_id = pt.photo_id
JOIN users u ON ph.user_id = u.user_id
WHERE pt.user_id = 1
ORDER BY ph.created_at DESC;
```

**Use Case:** "Photos of You"

---

### 9. MESSAGING QUERIES

#### Query 9.1: Get User's Conversations
```sql
SELECT 
    c.conversation_id,
    c.is_group_chat,
    c.name,
    -- Get last message
    (SELECT content FROM messages WHERE conversation_id = c.conversation_id ORDER BY sent_at DESC LIMIT 1) AS last_message,
    (SELECT sent_at FROM messages WHERE conversation_id = c.conversation_id ORDER BY sent_at DESC LIMIT 1) AS last_message_time,
    -- Get unread count
    (SELECT COUNT(*) FROM messages m 
     WHERE m.conversation_id = c.conversation_id 
       AND m.sender_id != 1 
       AND m.is_read = FALSE) AS unread_count
FROM conversations c
JOIN conversation_participants cp ON c.conversation_id = cp.conversation_id
WHERE cp.user_id = 1
ORDER BY last_message_time DESC;
```

**Use Case:** Messenger inbox

#### Query 9.2: Get Conversation Messages
```sql
SELECT 
    m.message_id,
    m.content,
    m.sent_at,
    m.is_read,
    u.user_id,
    u.first_name,
    u.last_name,
    u.profile_picture_url
FROM messages m
JOIN users u ON m.sender_id = u.user_id
WHERE m.conversation_id = 100
ORDER BY m.sent_at ASC;
```

**Use Case:** Message thread

---

### 10. NOTIFICATION QUERIES

#### Query 10.1: Get Recent Notifications
```sql
SELECT 
    n.notification_id,
    n.type,
    n.is_read,
    n.created_at,
    actor.first_name AS actor_first_name,
    actor.last_name AS actor_last_name,
    actor.profile_picture_url AS actor_photo
FROM notifications n
LEFT JOIN users actor ON n.actor_user_id = actor.user_id
WHERE n.user_id = 1
ORDER BY n.created_at DESC
LIMIT 20;
```

**Use Case:** Notifications dropdown

#### Query 10.2: Get Unread Notification Count
```sql
SELECT COUNT(*) AS unread_count
FROM notifications
WHERE user_id = 1 AND is_read = FALSE;
```

**Use Case:** Notification badge

---

## Performance Optimization Tips

### 1. Essential Indexes
```sql
CREATE INDEX idx_friendships_users ON friendships(user_id_1, user_id_2);
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at);
CREATE INDEX idx_posts_group ON posts(group_id, created_at);
CREATE INDEX idx_reactions_post ON reactions(post_id);
CREATE INDEX idx_comments_post ON comments(post_id, parent_comment_id);
CREATE INDEX idx_group_members_user ON group_members(user_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id, sent_at);
```

### 2. Denormalized Counts
- users.friends_count
- posts.reactions_count, comments_count, shares_count
- groups.members_count
- pages.followers_count

### 3. Caching Strategy
- User profiles
- Friend lists
- News feed (Redis)
- Notification counts

### 4. Partitioning
- posts: By created_at (monthly)
- messages: By sent_at
- notifications: By created_at

---

## Summary

These queries demonstrate:
- ✅ Bidirectional friendship queries
- ✅ News feed generation
- ✅ Multiple reaction types
- ✅ Nested comments
- ✅ Group management
- ✅ Event RSVPs
- ✅ Photo tagging
- ✅ Messaging
- ✅ Notifications

**Key Facebook Features:**
1. Bidirectional friendships (vs Twitter follow)
2. Friend requests workflow
3. 6 reaction types
4. Nested comments
5. Groups with roles
6. Pages (business)
7. Events with RSVPs
8. Photo albums and tagging
9. Group chats
10. Rich notifications

---

These queries form the foundation for building a fully functional Facebook-like application!
