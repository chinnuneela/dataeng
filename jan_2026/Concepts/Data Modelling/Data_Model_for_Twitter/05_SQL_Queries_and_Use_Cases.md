# Step 5: SQL Queries and Use Cases

## Introduction

This document demonstrates how to query the Twitter data model to answer real-world questions. Each query includes:
- **Business Question**: What we're trying to find
- **SQL Query**: The actual code
- **Explanation**: How it works
- **Use Case**: When you'd use this

---

## Query Categories

1. User Queries
2. Tweet Queries
3. Timeline Queries
4. Engagement Queries
5. Discovery Queries
6. Analytics Queries
7. Messaging Queries
8. Notification Queries

---

## 1. USER QUERIES

### Query 1.1: Get User Profile with Stats

**Business Question:** Display a user's complete profile with all statistics

**SQL Query:**
```sql
SELECT 
    u.user_id,
    u.username,
    u.display_name,
    u.bio,
    u.profile_image_url,
    u.location,
    u.website,
    u.is_verified,
    u.created_at,
    u.followers_count,
    u.following_count,
    u.tweets_count
FROM users u
WHERE u.username = 'elonmusk';
```

**Explanation:**
- Simple SELECT from users table
- Uses denormalized counts for performance
- Filter by username (indexed for speed)

**Use Case:** Profile page display

---

### Query 1.2: Get User's Followers

**Business Question:** Who follows a specific user?

**SQL Query:**
```sql
SELECT 
    u.user_id,
    u.username,
    u.display_name,
    u.profile_image_url,
    u.is_verified,
    f.followed_at
FROM follows f
JOIN users u ON f.follower_id = u.user_id
WHERE f.following_id = (
    SELECT user_id FROM users WHERE username = 'elonmusk'
)
ORDER BY f.followed_at DESC
LIMIT 50;
```

**Explanation:**
- JOIN follows table with users
- follower_id = users who follow
- following_id = user being followed
- Order by most recent followers

**Use Case:** "Followers" page

---

### Query 1.3: Get Users Someone Follows

**Business Question:** Who does a user follow?

**SQL Query:**
```sql
SELECT 
    u.user_id,
    u.username,
    u.display_name,
    u.profile_image_url,
    u.is_verified,
    f.followed_at
FROM follows f
JOIN users u ON f.following_id = u.user_id
WHERE f.follower_id = (
    SELECT user_id FROM users WHERE username = 'elonmusk'
)
ORDER BY f.followed_at DESC;
```

**Explanation:**
- Similar to followers query
- But follower_id = the user
- following_id = users they follow

**Use Case:** "Following" page

---

### Query 1.4: Find Mutual Follows

**Business Question:** Which users follow each other?

**SQL Query:**
```sql
SELECT 
    u.user_id,
    u.username,
    u.display_name
FROM follows f1
JOIN follows f2 ON f1.follower_id = f2.following_id 
    AND f1.following_id = f2.follower_id
JOIN users u ON f1.following_id = u.user_id
WHERE f1.follower_id = (
    SELECT user_id FROM users WHERE username = 'elonmusk'
);
```

**Explanation:**
- Self-join on follows table
- f1: User A follows User B
- f2: User B follows User A
- Both conditions must be true

**Use Case:** "Friends" feature, connection suggestions

---

### Query 1.5: Check if User A Follows User B

**Business Question:** Does user A follow user B?

**SQL Query:**
```sql
SELECT EXISTS (
    SELECT 1
    FROM follows
    WHERE follower_id = (SELECT user_id FROM users WHERE username = 'user_a')
      AND following_id = (SELECT user_id FROM users WHERE username = 'user_b')
) AS is_following;
```

**Explanation:**
- EXISTS returns TRUE/FALSE
- Efficient check without returning data
- Used for "Follow" button state

**Use Case:** Display "Follow" vs "Following" button

---

## 2. TWEET QUERIES

### Query 2.1: Get User's Tweets

**Business Question:** Show all tweets by a specific user

**SQL Query:**
```sql
SELECT 
    t.tweet_id,
    t.tweet_text,
    t.tweet_type,
    t.created_at,
    t.likes_count,
    t.retweets_count,
    t.replies_count,
    t.media_url,
    u.username,
    u.display_name,
    u.profile_image_url,
    u.is_verified
FROM tweets t
JOIN users u ON t.user_id = u.user_id
WHERE u.username = 'elonmusk'
  AND t.is_deleted = FALSE
  AND t.tweet_type IN ('original', 'quote')  -- Exclude pure retweets
ORDER BY t.created_at DESC
LIMIT 20;
```

**Explanation:**
- JOIN to get user info
- Filter by username
- Exclude deleted tweets
- Exclude pure retweets (show originals and quotes)
- Order by newest first

**Use Case:** User profile tweet list

---

### Query 2.2: Get Single Tweet with Details

**Business Question:** Show complete tweet information

**SQL Query:**
```sql
SELECT 
    t.tweet_id,
    t.tweet_text,
    t.tweet_type,
    t.created_at,
    t.likes_count,
    t.retweets_count,
    t.replies_count,
    t.views_count,
    t.media_url,
    u.user_id,
    u.username,
    u.display_name,
    u.profile_image_url,
    u.is_verified,
    -- Get parent tweet if reply
    parent_t.tweet_id AS parent_tweet_id,
    parent_t.tweet_text AS parent_tweet_text,
    parent_u.username AS parent_username
FROM tweets t
JOIN users u ON t.user_id = u.user_id
LEFT JOIN tweets parent_t ON t.reply_to_tweet_id = parent_t.tweet_id
LEFT JOIN users parent_u ON parent_t.user_id = parent_u.user_id
WHERE t.tweet_id = 123456789
  AND t.is_deleted = FALSE;
```

**Explanation:**
- Main tweet with user info
- LEFT JOIN for parent tweet (if reply)
- NULL if not a reply
- Complete context for display

**Use Case:** Tweet detail page

---

### Query 2.3: Get Tweet Thread (Conversation)

**Business Question:** Show entire conversation thread

**SQL Query:**
```sql
-- Recursive CTE to get full thread
WITH RECURSIVE thread AS (
    -- Base case: Get root tweet
    SELECT 
        t.tweet_id,
        t.user_id,
        t.tweet_text,
        t.reply_to_tweet_id,
        t.created_at,
        0 AS depth
    FROM tweets t
    WHERE t.tweet_id = 123456789  -- Starting tweet
    
    UNION ALL
    
    -- Recursive case: Get replies
    SELECT 
        t.tweet_id,
        t.user_id,
        t.tweet_text,
        t.reply_to_tweet_id,
        t.created_at,
        th.depth + 1
    FROM tweets t
    JOIN thread th ON t.reply_to_tweet_id = th.tweet_id
    WHERE t.is_deleted = FALSE
)
SELECT 
    th.tweet_id,
    th.tweet_text,
    th.created_at,
    th.depth,
    u.username,
    u.display_name,
    u.profile_image_url
FROM thread th
JOIN users u ON th.user_id = u.user_id
ORDER BY th.created_at;
```

**Explanation:**
- Recursive CTE walks the reply chain
- depth tracks nesting level
- Starts from specific tweet
- Gets all descendants

**Use Case:** "Show this thread" feature

---

### Query 2.4: Get Tweets with Specific Hashtag

**Business Question:** Find all tweets containing a hashtag

**SQL Query:**
```sql
SELECT 
    t.tweet_id,
    t.tweet_text,
    t.created_at,
    t.likes_count,
    t.retweets_count,
    u.username,
    u.display_name,
    u.profile_image_url
FROM tweets t
JOIN users u ON t.user_id = u.user_id
JOIN tweet_hashtags th ON t.tweet_id = th.tweet_id
JOIN hashtags h ON th.hashtag_id = h.hashtag_id
WHERE h.hashtag_text = 'javascript'
  AND t.is_deleted = FALSE
ORDER BY t.created_at DESC
LIMIT 50;
```

**Explanation:**
- JOIN through tweet_hashtags junction table
- Filter by hashtag text
- Order by recency

**Use Case:** Hashtag search, trending topics

---

### Query 2.5: Get Tweets Mentioning User

**Business Question:** Find tweets that mention a specific user

**SQL Query:**
```sql
SELECT 
    t.tweet_id,
    t.tweet_text,
    t.created_at,
    u.username AS author_username,
    u.display_name AS author_name
FROM tweets t
JOIN users u ON t.user_id = u.user_id
JOIN mentions m ON t.tweet_id = m.tweet_id
WHERE m.mentioned_user_id = (
    SELECT user_id FROM users WHERE username = 'elonmusk'
)
  AND t.is_deleted = FALSE
ORDER BY t.created_at DESC
LIMIT 50;
```

**Explanation:**
- JOIN through mentions table
- Filter by mentioned user
- Shows who's talking about the user

**Use Case:** "Mentions" tab, notifications

---

## 3. TIMELINE QUERIES

### Query 3.1: Home Timeline (Following Feed)

**Business Question:** Show tweets from users I follow

**SQL Query:**
```sql
SELECT 
    t.tweet_id,
    t.tweet_text,
    t.tweet_type,
    t.created_at,
    t.likes_count,
    t.retweets_count,
    t.replies_count,
    t.media_url,
    u.user_id,
    u.username,
    u.display_name,
    u.profile_image_url,
    u.is_verified
FROM tweets t
JOIN users u ON t.user_id = u.user_id
WHERE t.user_id IN (
    -- Users I follow
    SELECT following_id 
    FROM follows 
    WHERE follower_id = 1  -- Current user ID
)
  AND t.is_deleted = FALSE
ORDER BY t.created_at DESC
LIMIT 50;
```

**Explanation:**
- Subquery gets users I follow
- Main query gets their tweets
- Order by newest first
- This is the core "timeline" query

**Use Case:** Home feed, main timeline

**Optimization:**
- Cache following list
- Use materialized view
- Partition tweets by date

---

### Query 3.2: Timeline with Engagement Status

**Business Question:** Show timeline with "liked by me" status

**SQL Query:**
```sql
SELECT 
    t.tweet_id,
    t.tweet_text,
    t.created_at,
    t.likes_count,
    t.retweets_count,
    u.username,
    u.display_name,
    -- Check if current user liked this tweet
    EXISTS (
        SELECT 1 FROM likes 
        WHERE tweet_id = t.tweet_id AND user_id = 1
    ) AS liked_by_me,
    -- Check if current user retweeted
    EXISTS (
        SELECT 1 FROM retweets 
        WHERE tweet_id = t.tweet_id AND user_id = 1
    ) AS retweeted_by_me,
    -- Check if current user bookmarked
    EXISTS (
        SELECT 1 FROM bookmarks 
        WHERE tweet_id = t.tweet_id AND user_id = 1
    ) AS bookmarked_by_me
FROM tweets t
JOIN users u ON t.user_id = u.user_id
WHERE t.user_id IN (
    SELECT following_id FROM follows WHERE follower_id = 1
)
  AND t.is_deleted = FALSE
ORDER BY t.created_at DESC
LIMIT 20;
```

**Explanation:**
- EXISTS checks for engagement
- Returns boolean for UI state
- Shows heart icon filled/unfilled
- Enables proper button states

**Use Case:** Interactive timeline with engagement indicators

---

## 4. ENGAGEMENT QUERIES

### Query 4.1: Get Users Who Liked a Tweet

**Business Question:** Who liked this tweet?

**SQL Query:**
```sql
SELECT 
    u.user_id,
    u.username,
    u.display_name,
    u.profile_image_url,
    u.is_verified,
    l.liked_at
FROM likes l
JOIN users u ON l.user_id = u.user_id
WHERE l.tweet_id = 123456789
ORDER BY l.liked_at DESC
LIMIT 100;
```

**Explanation:**
- JOIN likes with users
- Filter by tweet
- Order by most recent likes

**Use Case:** "Liked by" modal

---

### Query 4.2: Get User's Liked Tweets

**Business Question:** What tweets has a user liked?

**SQL Query:**
```sql
SELECT 
    t.tweet_id,
    t.tweet_text,
    t.created_at,
    l.liked_at,
    u.username,
    u.display_name,
    u.profile_image_url
FROM likes l
JOIN tweets t ON l.tweet_id = t.tweet_id
JOIN users u ON t.user_id = u.user_id
WHERE l.user_id = (SELECT user_id FROM users WHERE username = 'elonmusk')
  AND t.is_deleted = FALSE
ORDER BY l.liked_at DESC
LIMIT 50;
```

**Explanation:**
- Start from likes table
- JOIN to get tweet details
- JOIN to get tweet author
- Order by when liked

**Use Case:** "Likes" tab on profile

---

### Query 4.3: Get Tweet Replies

**Business Question:** Show all replies to a tweet

**SQL Query:**
```sql
SELECT 
    t.tweet_id,
    t.tweet_text,
    t.created_at,
    t.likes_count,
    t.replies_count,
    u.user_id,
    u.username,
    u.display_name,
    u.profile_image_url,
    u.is_verified
FROM tweets t
JOIN users u ON t.user_id = u.user_id
WHERE t.reply_to_tweet_id = 123456789
  AND t.is_deleted = FALSE
ORDER BY t.created_at ASC;  -- Chronological for conversation flow
```

**Explanation:**
- Filter by reply_to_tweet_id
- Gets direct replies only (not nested)
- Chronological order for readability

**Use Case:** Tweet detail page replies section

---

## 5. DISCOVERY QUERIES

### Query 5.1: Trending Hashtags

**Business Question:** What are the most popular hashtags right now?

**SQL Query:**
```sql
SELECT 
    h.hashtag_id,
    h.hashtag_text,
    COUNT(th.tweet_hashtag_id) AS tweet_count_24h
FROM hashtags h
JOIN tweet_hashtags th ON h.hashtag_id = th.hashtag_id
JOIN tweets t ON th.tweet_id = t.tweet_id
WHERE t.created_at >= NOW() - INTERVAL 24 HOUR
  AND t.is_deleted = FALSE
GROUP BY h.hashtag_id, h.hashtag_text
ORDER BY tweet_count_24h DESC
LIMIT 10;
```

**Explanation:**
- Count hashtag usage in last 24 hours
- JOIN through junction table
- Filter by time window
- Order by most used

**Use Case:** "Trending" sidebar

**Optimization:**
- Pre-calculate hourly
- Store in cache
- Use materialized view

---

### Query 5.2: Search Tweets by Keyword

**Business Question:** Find tweets containing specific text

**SQL Query:**
```sql
SELECT 
    t.tweet_id,
    t.tweet_text,
    t.created_at,
    t.likes_count,
    t.retweets_count,
    u.username,
    u.display_name,
    u.profile_image_url
FROM tweets t
JOIN users u ON t.user_id = u.user_id
WHERE t.tweet_text LIKE '%artificial intelligence%'
  AND t.is_deleted = FALSE
ORDER BY t.created_at DESC
LIMIT 50;
```

**Explanation:**
- LIKE for text search
- Case-insensitive matching
- Order by recency

**Use Case:** Search functionality

**Better Approach:**
- Use full-text search (MySQL FULLTEXT, PostgreSQL FTS)
- Or external search engine (Elasticsearch)

---

### Query 5.3: Suggested Users to Follow

**Business Question:** Who should I follow based on mutual connections?

**SQL Query:**
```sql
SELECT 
    u.user_id,
    u.username,
    u.display_name,
    u.profile_image_url,
    u.is_verified,
    u.followers_count,
    COUNT(DISTINCT f2.follower_id) AS mutual_connections
FROM users u
JOIN follows f1 ON u.user_id = f1.following_id
JOIN follows f2 ON f1.follower_id = f2.follower_id
WHERE f2.following_id IN (
    -- People I follow
    SELECT following_id FROM follows WHERE follower_id = 1
)
  AND u.user_id != 1  -- Not myself
  AND u.user_id NOT IN (
    -- People I already follow
    SELECT following_id FROM follows WHERE follower_id = 1
  )
GROUP BY u.user_id
ORDER BY mutual_connections DESC, u.followers_count DESC
LIMIT 10;
```

**Explanation:**
- Find users followed by people I follow
- Count mutual connections
- Exclude users I already follow
- Order by relevance

**Use Case:** "Who to follow" suggestions

---

## 6. ANALYTICS QUERIES

### Query 6.1: User Engagement Stats

**Business Question:** Calculate user's engagement metrics

**SQL Query:**
```sql
SELECT 
    u.username,
    u.tweets_count,
    u.followers_count,
    u.following_count,
    -- Total likes received
    SUM(t.likes_count) AS total_likes_received,
    -- Total retweets received
    SUM(t.retweets_count) AS total_retweets_received,
    -- Average engagement per tweet
    AVG(t.likes_count + t.retweets_count + t.replies_count) AS avg_engagement,
    -- Most liked tweet
    MAX(t.likes_count) AS most_liked_tweet
FROM users u
LEFT JOIN tweets t ON u.user_id = t.user_id AND t.is_deleted = FALSE
WHERE u.username = 'elonmusk'
GROUP BY u.user_id;
```

**Explanation:**
- Aggregate engagement metrics
- Calculate averages and totals
- Useful for analytics dashboard

**Use Case:** User analytics, influencer metrics

---

### Query 6.2: Most Engaging Tweets

**Business Question:** What are the most popular tweets?

**SQL Query:**
```sql
SELECT 
    t.tweet_id,
    t.tweet_text,
    t.created_at,
    t.likes_count,
    t.retweets_count,
    t.replies_count,
    (t.likes_count + t.retweets_count * 2 + t.replies_count * 3) AS engagement_score,
    u.username,
    u.display_name
FROM tweets t
JOIN users u ON t.user_id = u.user_id
WHERE t.created_at >= NOW() - INTERVAL 7 DAY
  AND t.is_deleted = FALSE
ORDER BY engagement_score DESC
LIMIT 20;
```

**Explanation:**
- Weighted engagement score
- Retweets worth 2x likes
- Replies worth 3x likes
- Last 7 days only

**Use Case:** "Top tweets" feature, viral content

---

### Query 6.3: User Activity Timeline

**Business Question:** When is a user most active?

**SQL Query:**
```sql
SELECT 
    HOUR(created_at) AS hour_of_day,
    COUNT(*) AS tweet_count
FROM tweets
WHERE user_id = (SELECT user_id FROM users WHERE username = 'elonmusk')
  AND created_at >= NOW() - INTERVAL 30 DAY
  AND is_deleted = FALSE
GROUP BY HOUR(created_at)
ORDER BY hour_of_day;
```

**Explanation:**
- Extract hour from timestamp
- Count tweets per hour
- Last 30 days
- Shows activity pattern

**Use Case:** User behavior analysis

---

## 7. MESSAGING QUERIES

### Query 7.1: Get Conversation Between Two Users

**Business Question:** Show message history

**SQL Query:**
```sql
SELECT 
    m.message_id,
    m.message_text,
    m.sent_at,
    m.is_read,
    sender.username AS sender_username,
    sender.display_name AS sender_name,
    receiver.username AS receiver_username
FROM messages m
JOIN users sender ON m.sender_id = sender.user_id
JOIN users receiver ON m.receiver_id = receiver.user_id
WHERE (m.sender_id = 1 AND m.receiver_id = 2)
   OR (m.sender_id = 2 AND m.receiver_id = 1)
ORDER BY m.sent_at ASC;
```

**Explanation:**
- Bidirectional conversation
- Both directions included
- Chronological order

**Use Case:** Direct message thread

---

### Query 7.2: Get Unread Message Count

**Business Question:** How many unread messages?

**SQL Query:**
```sql
SELECT COUNT(*) AS unread_count
FROM messages
WHERE receiver_id = 1
  AND is_read = FALSE;
```

**Explanation:**
- Simple count
- Filter by recipient and read status

**Use Case:** Notification badge

---

## 8. NOTIFICATION QUERIES

### Query 8.1: Get User's Recent Notifications

**Business Question:** Show notification feed

**SQL Query:**
```sql
SELECT 
    n.notification_id,
    n.notification_type,
    n.notification_text,
    n.created_at,
    n.is_read,
    actor.username AS actor_username,
    actor.display_name AS actor_name,
    actor.profile_image_url AS actor_image,
    t.tweet_text
FROM notifications n
LEFT JOIN users actor ON n.actor_user_id = actor.user_id
LEFT JOIN tweets t ON n.related_tweet_id = t.tweet_id
WHERE n.user_id = 1
ORDER BY n.created_at DESC
LIMIT 50;
```

**Explanation:**
- Get notifications with context
- LEFT JOIN for optional fields
- Order by newest first

**Use Case:** Notifications page

---

### Query 8.2: Mark Notifications as Read

**Business Question:** Update notification status

**SQL Query:**
```sql
UPDATE notifications
SET is_read = TRUE
WHERE user_id = 1
  AND is_read = FALSE;
```

**Explanation:**
- Bulk update
- Mark all as read

**Use Case:** "Mark all as read" button

---

## Query Performance Tips

### 1. Use Indexes
```sql
-- Essential indexes
CREATE INDEX idx_tweets_user_created ON tweets(user_id, created_at);
CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_following ON follows(following_id);
CREATE INDEX idx_likes_tweet ON likes(tweet_id);
CREATE INDEX idx_likes_user ON likes(user_id);
```

### 2. Denormalize Counts
- Store counts in main tables
- Update via triggers or application
- Trade write speed for read speed

### 3. Partition Large Tables
```sql
-- Partition tweets by month
ALTER TABLE tweets PARTITION BY RANGE (YEAR(created_at) * 100 + MONTH(created_at));
```

### 4. Use Caching
- Cache user profiles
- Cache follower lists
- Cache trending hashtags
- Use Redis/Memcached

### 5. Limit Results
- Always use LIMIT
- Implement pagination
- Don't fetch all rows

---

## Summary

These queries demonstrate:
- ✅ Basic CRUD operations
- ✅ Complex JOINs
- ✅ Subqueries
- ✅ Aggregations
- ✅ Recursive CTEs
- ✅ EXISTS checks
- ✅ Performance optimization

**Key Takeaways:**
1. Use indexes on foreign keys and frequently queried columns
2. Denormalize counts for performance
3. Use EXISTS for boolean checks
4. Implement pagination with LIMIT/OFFSET
5. Cache frequently accessed data
6. Partition large tables by date

---

These queries form the foundation for building a fully functional Twitter-like application!
