# Step 2: Entity Identification and Explanation

## What is an Entity?

An **entity** is a thing or object in the real world that:
- Has independent existence
- Can be uniquely identified
- Has attributes (properties)
- Participates in relationships

---

## Entity Selection Process

### How to Identify Entities:

1. **Look for Nouns** in requirements (User, Tweet, Message)
2. **Identify Things with Attributes** (User has name, email)
3. **Find Things That Relate** (Users follow Users)
4. **Separate Entities from Attributes** (Tweet vs Tweet Text)

---

## Twitter Entities - Complete List

### Core Entities (9):

1. **users** - Platform members
2. **tweets** - Posted content
3. **follows** - Follow relationships
4. **likes** - Tweet likes
5. **retweets** - Tweet shares
6. **hashtags** - Topic tags
7. **tweet_hashtags** - Tweet-hashtag mapping
8. **mentions** - User mentions in tweets
9. **messages** - Direct messages

### Supporting Entities (2):

10. **notifications** - User activity alerts
11. **bookmarks** - Saved tweets

---

## Detailed Entity Analysis

---

### Entity 1: USERS

**Purpose:** Store user account and profile information

**Why This is an Entity:**
- Users exist independently
- Have unique identity (user_id)
- Have multiple attributes
- Central to all platform activities

**Attributes:**

| Attribute | Data Type | Description | Why Needed |
|-----------|-----------|-------------|------------|
| user_id | INT (PK) | Unique identifier | Primary key, references |
| username | VARCHAR(50) | Display name (@username) | User identity, mentions |
| email | VARCHAR(100) | Contact email | Authentication, unique |
| password_hash | VARCHAR(255) | Encrypted password | Security |
| display_name | VARCHAR(100) | Full name | Profile display |
| bio | TEXT | User biography | Profile information |
| profile_image_url | VARCHAR(500) | Profile picture | Visual identity |
| banner_image_url | VARCHAR(500) | Header image | Profile customization |
| location | VARCHAR(100) | User location | Profile info |
| website | VARCHAR(200) | Personal website | External link |
| is_verified | BOOLEAN | Verification status | Trust indicator |
| is_private | BOOLEAN | Account privacy | Content visibility |
| created_at | TIMESTAMP | Account creation | User history |
| followers_count | INT | Number of followers | Social proof (denormalized) |
| following_count | INT | Number following | Activity metric (denormalized) |
| tweets_count | INT | Total tweets | Activity metric (denormalized) |

**Business Rules:**
- Username must be unique
- Email must be unique
- Username: 1-50 characters, alphanumeric + underscore
- Bio: max 160 characters
- Counts are denormalized for performance

**Why Denormalize Counts:**
- Frequently displayed (every profile view)
- Expensive to calculate on-the-fly
- Can be updated via triggers or application logic

---

### Entity 2: TWEETS

**Purpose:** Store all posted content (tweets, retweets, replies)

**Why This is an Entity:**
- Tweets are the core content
- Exist independently
- Have unique identity
- Multiple types (original, retweet, reply)

**Attributes:**

| Attribute | Data Type | Description | Why Needed |
|-----------|-----------|-------------|------------|
| tweet_id | BIGINT (PK) | Unique identifier | Primary key (BIGINT for scale) |
| user_id | INT (FK) | Tweet author | Ownership |
| tweet_text | VARCHAR(280) | Tweet content | Core content |
| tweet_type | ENUM | Type of tweet | Distinguish types |
| reply_to_tweet_id | BIGINT (FK) | Parent tweet if reply | Threading |
| retweet_of_tweet_id | BIGINT (FK) | Original tweet if RT | Retweet tracking |
| quote_tweet_id | BIGINT (FK) | Quoted tweet | Quote tweets |
| media_url | VARCHAR(500) | Media attachment | Rich content |
| media_type | ENUM | Type of media | Media handling |
| created_at | TIMESTAMP | Post timestamp | Chronology |
| updated_at | TIMESTAMP | Last edit time | Edit tracking |
| is_deleted | BOOLEAN | Soft delete flag | Data preservation |
| likes_count | INT | Number of likes | Engagement (denormalized) |
| retweets_count | INT | Number of retweets | Virality (denormalized) |
| replies_count | INT | Number of replies | Conversation (denormalized) |
| views_count | BIGINT | Impression count | Analytics |

**Tweet Types (ENUM):**
- `original` - Regular tweet
- `reply` - Reply to another tweet
- `retweet` - Share of another tweet
- `quote` - Retweet with comment

**Business Rules:**
- Tweet text: max 280 characters
- Deleted tweets: soft delete (is_deleted = TRUE)
- Replies must reference valid tweet
- Retweets must reference valid tweet
- One tweet can be either reply OR retweet OR quote (not multiple)

**Why Self-Referencing:**
- Replies reference parent tweets
- Creates conversation threads
- Enables nested discussions

---

### Entity 3: FOLLOWS

**Purpose:** Track follower/following relationships

**Why This is an Entity (Not Just Attributes):**
- Represents a relationship, not just data
- Many-to-many relationship needs junction table
- Has its own attributes (followed_at)
- Users follow many users, users have many followers

**Attributes:**

| Attribute | Data Type | Description | Why Needed |
|-----------|-----------|-------------|------------|
| follow_id | INT (PK) | Unique identifier | Primary key |
| follower_id | INT (FK) | User who follows | Source of relationship |
| following_id | INT (FK) | User being followed | Target of relationship |
| followed_at | TIMESTAMP | When follow occurred | Relationship history |

**Business Rules:**
- follower_id ≠ following_id (can't follow yourself)
- Unique constraint on (follower_id, following_id)
- Directional relationship (A follows B ≠ B follows A)

**Why Junction Table:**
- Many-to-many relationship
- One user follows many users
- One user has many followers
- Allows relationship attributes (followed_at)

---

### Entity 4: LIKES

**Purpose:** Track which users liked which tweets

**Why This is an Entity:**
- Many-to-many relationship (users ↔ tweets)
- Has relationship attribute (liked_at)
- Needs to prevent duplicates
- Supports unlike functionality

**Attributes:**

| Attribute | Data Type | Description | Why Needed |
|-----------|-----------|-------------|------------|
| like_id | BIGINT (PK) | Unique identifier | Primary key |
| user_id | INT (FK) | User who liked | Source |
| tweet_id | BIGINT (FK) | Liked tweet | Target |
| liked_at | TIMESTAMP | When liked | Timeline |

**Business Rules:**
- One user can like a tweet only once
- Unique constraint on (user_id, tweet_id)
- Unlike = DELETE from table

**Why Not Just a Boolean in Tweets:**
- Need to know WHO liked
- Need to know WHEN liked
- Support user's "liked tweets" page
- Many-to-many relationship

---

### Entity 5: RETWEETS

**Purpose:** Track who retweeted which tweets

**Why Separate from Tweets Table:**
- Retweets create new tweet entries
- But we also need to track the retweet action
- Supports "retweeted by" feature
- Prevents duplicate retweets

**Attributes:**

| Attribute | Data Type | Description | Why Needed |
|-----------|-----------|-------------|------------|
| retweet_id | BIGINT (PK) | Unique identifier | Primary key |
| user_id | INT (FK) | User who retweeted | Source |
| tweet_id | BIGINT (FK) | Original tweet | Target |
| retweeted_at | TIMESTAMP | When retweeted | Timeline |

**Business Rules:**
- One user can retweet a tweet only once
- Unique constraint on (user_id, tweet_id)
- Undo retweet = DELETE from table

**Relationship with Tweets Table:**
- Retweet also creates entry in tweets table
- retweet_of_tweet_id points to original
- This table tracks the ACTION of retweeting

---

### Entity 6: HASHTAGS

**Purpose:** Master list of all hashtags used on platform

**Why This is an Entity:**
- Hashtags exist independently
- Reused across many tweets
- Need to track trending hashtags
- Normalization (avoid storing same hashtag text repeatedly)

**Attributes:**

| Attribute | Data Type | Description | Why Needed |
|-----------|-----------|-------------|------------|
| hashtag_id | INT (PK) | Unique identifier | Primary key |
| hashtag_text | VARCHAR(100) | Hashtag content | The actual tag |
| created_at | TIMESTAMP | First use | History |
| usage_count | INT | Times used | Trending calculation |

**Business Rules:**
- hashtag_text is unique (case-insensitive)
- Stored without '#' symbol
- Lowercase normalized
- Usage count updated on each use

**Why Separate Table:**
- Avoid storing "#JavaScript" 1000 times
- Enable trending hashtag queries
- Track hashtag history
- Normalize data

---

### Entity 7: TWEET_HASHTAGS

**Purpose:** Link tweets to hashtags (junction table)

**Why This is an Entity:**
- Many-to-many relationship
- One tweet has many hashtags
- One hashtag appears in many tweets
- Junction table required

**Attributes:**

| Attribute | Data Type | Description | Why Needed |
|-----------|-----------|-------------|------------|
| tweet_hashtag_id | INT (PK) | Unique identifier | Primary key |
| tweet_id | BIGINT (FK) | Tweet containing hashtag | Source |
| hashtag_id | INT (FK) | Hashtag used | Target |
| created_at | TIMESTAMP | When tagged | Timeline |

**Business Rules:**
- One tweet can have multiple hashtags
- Same hashtag can appear once per tweet
- Unique constraint on (tweet_id, hashtag_id)

**Why Not Store in Tweets Table:**
- One tweet can have 0-10+ hashtags
- Would require array or multiple columns
- Violates 1NF (atomic values)
- Makes querying difficult

---

### Entity 8: MENTIONS

**Purpose:** Track user mentions in tweets

**Why This is an Entity:**
- Many-to-many relationship
- One tweet mentions many users
- One user mentioned in many tweets
- Enables mention notifications

**Attributes:**

| Attribute | Data Type | Description | Why Needed |
|-----------|-----------|-------------|------------|
| mention_id | BIGINT (PK) | Unique identifier | Primary key |
| tweet_id | BIGINT (FK) | Tweet with mention | Source |
| mentioned_user_id | INT (FK) | User mentioned | Target |
| created_at | TIMESTAMP | When mentioned | Notifications |

**Business Rules:**
- One tweet can mention multiple users
- Same user can be mentioned once per tweet
- Mentioned user must exist

**Why This is Important:**
- Powers mention notifications
- Enables "tweets mentioning you" page
- Tracks user engagement
- Supports @username search

---

### Entity 9: MESSAGES

**Purpose:** Direct messages between users

**Why This is an Entity:**
- Messages exist independently
- Private communication
- Separate from public tweets
- Has unique attributes

**Attributes:**

| Attribute | Data Type | Description | Why Needed |
|-----------|-----------|-------------|------------|
| message_id | BIGINT (PK) | Unique identifier | Primary key |
| sender_id | INT (FK) | User sending | Source |
| receiver_id | INT (FK) | User receiving | Target |
| message_text | TEXT | Message content | Core content |
| media_url | VARCHAR(500) | Media attachment | Rich messaging |
| sent_at | TIMESTAMP | Send time | Chronology |
| is_read | BOOLEAN | Read status | Read receipts |
| read_at | TIMESTAMP | When read | Read tracking |

**Business Rules:**
- sender_id ≠ receiver_id (can't message yourself)
- Messages are private (not in public timeline)
- Can send multiple messages to same user

**Why Separate from Tweets:**
- Different privacy model
- Different UI/UX
- Different notification rules
- Simpler schema

---

### Entity 10: NOTIFICATIONS

**Purpose:** Alert users of platform activity

**Why This is an Entity:**
- Notifications exist independently
- Track read/unread status
- Support different notification types
- Enable notification history

**Attributes:**

| Attribute | Data Type | Description | Why Needed |
|-----------|-----------|-------------|------------|
| notification_id | BIGINT (PK) | Unique identifier | Primary key |
| user_id | INT (FK) | Recipient user | Target |
| notification_type | ENUM | Type of notification | Categorization |
| actor_user_id | INT (FK) | User who triggered | Source |
| related_tweet_id | BIGINT (FK) | Related tweet | Context |
| notification_text | TEXT | Notification message | Display |
| is_read | BOOLEAN | Read status | UI state |
| created_at | TIMESTAMP | When created | Chronology |

**Notification Types:**
- `like` - Someone liked your tweet
- `retweet` - Someone retweeted your tweet
- `reply` - Someone replied to your tweet
- `follow` - Someone followed you
- `mention` - Someone mentioned you
- `message` - New direct message

**Business Rules:**
- Notifications are user-specific
- Can be marked as read
- Ordered by created_at (newest first)

---

### Entity 11: BOOKMARKS

**Purpose:** Save tweets for later reading

**Why This is an Entity:**
- Many-to-many relationship
- One user bookmarks many tweets
- One tweet bookmarked by many users
- Private to each user

**Attributes:**

| Attribute | Data Type | Description | Why Needed |
|-----------|-----------|-------------|------------|
| bookmark_id | BIGINT (PK) | Unique identifier | Primary key |
| user_id | INT (FK) | User who bookmarked | Owner |
| tweet_id | BIGINT (FK) | Bookmarked tweet | Target |
| bookmarked_at | TIMESTAMP | When bookmarked | Chronology |

**Business Rules:**
- One user can bookmark a tweet only once
- Unique constraint on (user_id, tweet_id)
- Bookmarks are private (not visible to others)

---

## Entity Relationship Summary

| Entity | Type | Relationships |
|--------|------|---------------|
| users | Core | Creates tweets, follows users, likes tweets, sends messages |
| tweets | Core | Belongs to user, has hashtags, mentions users, replies to tweets |
| follows | Junction | Links users to users |
| likes | Junction | Links users to tweets |
| retweets | Junction | Links users to tweets |
| hashtags | Core | Used in many tweets |
| tweet_hashtags | Junction | Links tweets to hashtags |
| mentions | Junction | Links tweets to users |
| messages | Core | Sent between users |
| notifications | Supporting | Sent to users |
| bookmarks | Junction | Links users to tweets |

---

## Why These Entities?

### Completeness:
✅ Covers all core Twitter features
✅ Supports user interactions
✅ Enables content discovery
✅ Tracks engagement

### Normalization:
✅ No redundant data
✅ Each entity has single responsibility
✅ Proper use of junction tables
✅ Follows 3NF principles

### Scalability:
✅ Efficient for billions of tweets
✅ Supports high write throughput
✅ Enables proper indexing
✅ Allows partitioning

### Flexibility:
✅ Easy to add features
✅ Supports different tweet types
✅ Extensible schema
✅ Clear relationships

---

## Next Steps

Now that we've identified and explained all entities, we'll:

1. ✅ **Step 1:** Problem diagnosis
2. ✅ **Step 2:** Entity identification (CURRENT)
3. ⏭️ **Step 3:** Establish relationships
4. ⏭️ **Step 4:** Create data model diagram
5. ⏭️ **Step 5:** Write SQL queries

---

These 11 entities form the complete foundation for our Twitter data model!
