# Step 3: Establishing Relationships

## What is a Relationship?

A **relationship** defines how entities are connected and interact with each other. In databases, relationships are implemented through **foreign keys**.

---

## Types of Relationships

### 1. One-to-Many (1:N)
- One entity instance relates to many instances of another
- Example: One user creates many tweets
- **Implementation:** Foreign key in "many" side table

### 2. Many-to-Many (M:N)
- Many instances relate to many instances
- Example: Users like many tweets, tweets liked by many users
- **Implementation:** Junction/bridge table

### 3. One-to-One (1:1)
- One entity instance relates to exactly one instance of another
- Example: User has one profile (rare in our model)
- **Implementation:** Foreign key with UNIQUE constraint

### 4. Self-Referencing
- Entity relates to itself
- Example: Users follow users, tweets reply to tweets
- **Implementation:** Foreign key referencing same table

---

## Twitter Relationships - Complete Analysis

---

## Relationship 1: Users → Tweets

**Type:** One-to-Many (1:N)

**Description:** One user creates many tweets

**Why This Relationship:**
- Every tweet must have an author
- Users can post unlimited tweets
- Core content creation relationship

**Implementation:**
```sql
tweets.user_id → users.user_id
```

**Cardinality:**
- One user → Many tweets (0 to millions)
- One tweet → Exactly one user (mandatory)

**Business Rules:**
- Tweet MUST have a user (NOT NULL)
- User can have zero tweets (new account)
- Deleting user should handle tweets (CASCADE or SET NULL)

**SQL Constraint:**
```sql
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
```

**Why CASCADE:**
- If user deleted, their tweets should be removed
- Maintains data integrity
- Prevents orphaned tweets

**Queries Enabled:**
- Get all tweets by a user
- Get tweet's author information
- Count tweets per user

---

## Relationship 2: Users ↔ Users (Follows)

**Type:** Many-to-Many (M:N) Self-Referencing

**Description:** Users follow other users

**Why This Relationship:**
- Social network foundation
- Defines content distribution
- Bidirectional but asymmetric (A follows B ≠ B follows A)

**Implementation:**
```sql
follows.follower_id → users.user_id
follows.following_id → users.user_id
```

**Junction Table:** `follows`

**Cardinality:**
- One user can follow many users
- One user can have many followers
- Relationship is directional

**Business Rules:**
- User cannot follow themselves
- No duplicate follows
- Unfollow = DELETE relationship

**SQL Constraints:**
```sql
FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE
FOREIGN KEY (following_id) REFERENCES users(user_id) ON DELETE CASCADE
UNIQUE (follower_id, following_id)
CHECK (follower_id != following_id)
```

**Why Self-Referencing:**
- Both sides are users
- Creates social graph
- Enables network analysis

**Queries Enabled:**
- Get user's followers
- Get users someone follows
- Find mutual follows
- Calculate follower count

**Visual Representation:**
```
User A ──follows──> User B
User B ──follows──> User C
User C ──follows──> User A

(A follows B, B follows C, C follows A - circular but valid)
```

---

## Relationship 3: Users ↔ Tweets (Likes)

**Type:** Many-to-Many (M:N)

**Description:** Users like tweets

**Why This Relationship:**
- Engagement mechanism
- One user likes many tweets
- One tweet liked by many users

**Implementation:**
```sql
likes.user_id → users.user_id
likes.tweet_id → tweets.tweet_id
```

**Junction Table:** `likes`

**Cardinality:**
- One user → Many likes (0 to unlimited)
- One tweet → Many likes (0 to millions)

**Business Rules:**
- One user can like a tweet only once
- Unlike removes the like record
- Cannot like own tweets? (business decision)

**SQL Constraints:**
```sql
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id) ON DELETE CASCADE
UNIQUE (user_id, tweet_id)
```

**Queries Enabled:**
- Get all tweets liked by a user
- Get all users who liked a tweet
- Count likes per tweet
- Check if user liked specific tweet

---

## Relationship 4: Users ↔ Tweets (Retweets)

**Type:** Many-to-Many (M:N)

**Description:** Users retweet tweets

**Why This Relationship:**
- Content amplification
- Viral spread mechanism
- Similar to likes but creates new tweet

**Implementation:**
```sql
retweets.user_id → users.user_id
retweets.tweet_id → tweets.tweet_id
```

**Junction Table:** `retweets`

**Special Note:** Retweet also creates entry in `tweets` table with `retweet_of_tweet_id` set

**Cardinality:**
- One user → Many retweets
- One tweet → Many retweets

**Business Rules:**
- One user can retweet a tweet only once
- Undo retweet removes the record
- Retweet creates new tweet entry

**SQL Constraints:**
```sql
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id) ON DELETE CASCADE
UNIQUE (user_id, tweet_id)
```

**Dual Representation:**
1. **retweets table:** Tracks WHO retweeted WHAT
2. **tweets table:** The retweet itself (with retweet_of_tweet_id)

---

## Relationship 5: Tweets → Tweets (Replies)

**Type:** One-to-Many (1:N) Self-Referencing

**Description:** Tweets can be replies to other tweets

**Why This Relationship:**
- Conversation threading
- Creates discussion chains
- Enables nested replies

**Implementation:**
```sql
tweets.reply_to_tweet_id → tweets.tweet_id
```

**Cardinality:**
- One tweet → Many replies (0 to thousands)
- One reply → One parent tweet (optional)

**Business Rules:**
- reply_to_tweet_id can be NULL (original tweets)
- Creates conversation threads
- Deleted parent tweet handling needed

**SQL Constraint:**
```sql
FOREIGN KEY (reply_to_tweet_id) REFERENCES tweets(tweet_id) ON DELETE SET NULL
```

**Why SET NULL:**
- If parent tweet deleted, reply still exists
- Reply becomes orphaned but preserved
- Alternative: CASCADE (deletes entire thread)

**Thread Structure:**
```
Original Tweet (tweet_id: 1, reply_to_tweet_id: NULL)
  └─ Reply 1 (tweet_id: 2, reply_to_tweet_id: 1)
      └─ Reply 2 (tweet_id: 3, reply_to_tweet_id: 2)
  └─ Reply 3 (tweet_id: 4, reply_to_tweet_id: 1)
```

**Queries Enabled:**
- Get all replies to a tweet
- Get conversation thread
- Count replies
- Find root tweet of thread

---

## Relationship 6: Tweets → Tweets (Retweets Reference)

**Type:** One-to-Many (1:N) Self-Referencing

**Description:** Retweets reference original tweets

**Why This Relationship:**
- Track original content
- Attribute credit
- Calculate retweet count

**Implementation:**
```sql
tweets.retweet_of_tweet_id → tweets.tweet_id
```

**Cardinality:**
- One original tweet → Many retweets
- One retweet → One original tweet (optional)

**Business Rules:**
- retweet_of_tweet_id NULL for original tweets
- Points to original content
- Original tweet deletion affects retweets

**SQL Constraint:**
```sql
FOREIGN KEY (retweet_of_tweet_id) REFERENCES tweets(tweet_id) ON DELETE CASCADE
```

**Why CASCADE:**
- If original deleted, retweets lose context
- Remove retweets when original removed
- Maintains data integrity

---

## Relationship 7: Tweets ↔ Hashtags

**Type:** Many-to-Many (M:N)

**Description:** Tweets contain hashtags, hashtags appear in many tweets

**Why This Relationship:**
- Content categorization
- Topic discovery
- Trending calculation

**Implementation:**
```sql
tweet_hashtags.tweet_id → tweets.tweet_id
tweet_hashtags.hashtag_id → hashtags.hashtag_id
```

**Junction Table:** `tweet_hashtags`

**Cardinality:**
- One tweet → Many hashtags (0 to 10+)
- One hashtag → Many tweets (0 to millions)

**Business Rules:**
- Same hashtag can appear once per tweet
- Hashtags extracted from tweet text
- Case-insensitive matching

**SQL Constraints:**
```sql
FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id) ON DELETE CASCADE
FOREIGN KEY (hashtag_id) REFERENCES hashtags(hashtag_id) ON DELETE CASCADE
UNIQUE (tweet_id, hashtag_id)
```

**Queries Enabled:**
- Get all hashtags in a tweet
- Get all tweets with specific hashtag
- Find trending hashtags
- Search by hashtag

---

## Relationship 8: Tweets ↔ Users (Mentions)

**Type:** Many-to-Many (M:N)

**Description:** Tweets mention users

**Why This Relationship:**
- User engagement
- Notifications
- Conversation linking

**Implementation:**
```sql
mentions.tweet_id → tweets.tweet_id
mentions.mentioned_user_id → users.user_id
```

**Junction Table:** `mentions`

**Cardinality:**
- One tweet → Many mentions (0 to 10+)
- One user → Mentioned in many tweets

**Business Rules:**
- Same user mentioned once per tweet
- Mentioned user must exist
- Generates notification

**SQL Constraints:**
```sql
FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id) ON DELETE CASCADE
FOREIGN KEY (mentioned_user_id) REFERENCES users(user_id) ON DELETE CASCADE
UNIQUE (tweet_id, mentioned_user_id)
```

**Queries Enabled:**
- Get all mentions in a tweet
- Get all tweets mentioning a user
- Mention notifications
- @username search

---

## Relationship 9: Users ↔ Users (Messages)

**Type:** Many-to-Many (M:N) Self-Referencing

**Description:** Users send messages to other users

**Why This Relationship:**
- Private communication
- One user messages many users
- One user receives messages from many users

**Implementation:**
```sql
messages.sender_id → users.user_id
messages.receiver_id → users.user_id
```

**Cardinality:**
- One user → Sends many messages
- One user → Receives many messages

**Business Rules:**
- Cannot message yourself
- Multiple messages allowed between same users
- Messages are private

**SQL Constraints:**
```sql
FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE
FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE
CHECK (sender_id != receiver_id)
```

**Queries Enabled:**
- Get conversation between two users
- Get all messages sent by user
- Get all messages received by user
- Unread message count

---

## Relationship 10: Users → Notifications

**Type:** One-to-Many (1:N)

**Description:** Users receive notifications

**Why This Relationship:**
- Activity alerts
- User engagement
- Real-time updates

**Implementation:**
```sql
notifications.user_id → users.user_id
notifications.actor_user_id → users.user_id (optional)
notifications.related_tweet_id → tweets.tweet_id (optional)
```

**Cardinality:**
- One user → Many notifications (0 to thousands)

**Business Rules:**
- Notifications belong to one user
- Can reference actor (who triggered)
- Can reference related content

**SQL Constraints:**
```sql
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
FOREIGN KEY (actor_user_id) REFERENCES users(user_id) ON DELETE CASCADE
FOREIGN KEY (related_tweet_id) REFERENCES tweets(tweet_id) ON DELETE CASCADE
```

**Queries Enabled:**
- Get user's notifications
- Get unread notifications
- Mark notifications as read
- Notification count

---

## Relationship 11: Users ↔ Tweets (Bookmarks)

**Type:** Many-to-Many (M:N)

**Description:** Users bookmark tweets for later

**Why This Relationship:**
- Personal curation
- Save for later
- Private to user

**Implementation:**
```sql
bookmarks.user_id → users.user_id
bookmarks.tweet_id → tweets.tweet_id
```

**Junction Table:** `bookmarks`

**Cardinality:**
- One user → Many bookmarks
- One tweet → Bookmarked by many users

**Business Rules:**
- One user bookmarks tweet once
- Bookmarks are private
- Remove bookmark = DELETE

**SQL Constraints:**
```sql
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id) ON DELETE CASCADE
UNIQUE (user_id, tweet_id)
```

**Queries Enabled:**
- Get user's bookmarks
- Check if tweet bookmarked
- Bookmark count per user

---

## Relationship Summary Table

| Relationship | Type | From | To | Junction Table | Cardinality |
|--------------|------|------|----|----|-------------|
| User creates Tweet | 1:N | users | tweets | - | 1 user → N tweets |
| User follows User | M:N | users | users | follows | M users ↔ N users |
| User likes Tweet | M:N | users | tweets | likes | M users ↔ N tweets |
| User retweets Tweet | M:N | users | tweets | retweets | M users ↔ N tweets |
| Tweet replies to Tweet | 1:N | tweets | tweets | - | 1 tweet → N replies |
| Tweet retweets Tweet | 1:N | tweets | tweets | - | 1 original → N RTs |
| Tweet has Hashtag | M:N | tweets | hashtags | tweet_hashtags | M tweets ↔ N hashtags |
| Tweet mentions User | M:N | tweets | users | mentions | M tweets ↔ N users |
| User messages User | M:N | users | users | messages | M users ↔ N users |
| User receives Notification | 1:N | users | notifications | - | 1 user → N notifications |
| User bookmarks Tweet | M:N | users | tweets | bookmarks | M users ↔ N tweets |

---

## Referential Integrity Actions

### ON DELETE CASCADE
**Used when:** Child data should be deleted with parent
**Examples:**
- Delete user → Delete their tweets
- Delete tweet → Delete its likes
- Delete tweet → Delete its hashtag associations

### ON DELETE SET NULL
**Used when:** Child data should remain but lose reference
**Examples:**
- Delete parent tweet → Replies become orphaned but kept

### ON DELETE RESTRICT
**Used when:** Prevent deletion if children exist
**Not used in our model** (we prefer CASCADE or SET NULL)

---

## Relationship Constraints Summary

### Unique Constraints (Prevent Duplicates):
- `follows(follower_id, following_id)` - No duplicate follows
- `likes(user_id, tweet_id)` - One like per user per tweet
- `retweets(user_id, tweet_id)` - One retweet per user per tweet
- `tweet_hashtags(tweet_id, hashtag_id)` - One hashtag per tweet
- `mentions(tweet_id, mentioned_user_id)` - One mention per user per tweet
- `bookmarks(user_id, tweet_id)` - One bookmark per user per tweet

### Check Constraints (Business Rules):
- `follows`: follower_id ≠ following_id
- `messages`: sender_id ≠ receiver_id
- `tweets`: tweet_text length ≤ 280

---

## Why These Relationships Matter

### Data Integrity:
✅ Foreign keys enforce valid references
✅ Cascading deletes maintain consistency
✅ Unique constraints prevent duplicates

### Query Performance:
✅ Proper indexing on foreign keys
✅ Junction tables enable efficient M:N queries
✅ Denormalized counts reduce joins

### Business Logic:
✅ Relationships model real-world interactions
✅ Enable complex features (threads, trending)
✅ Support analytics and recommendations

### Scalability:
✅ Normalized design reduces redundancy
✅ Clear relationships enable partitioning
✅ Junction tables scale independently

---

## Next Steps

Now that we've established all relationships, we'll:

1. ✅ **Step 1:** Problem diagnosis
2. ✅ **Step 2:** Entity identification
3. ✅ **Step 3:** Establish relationships (CURRENT)
4. ⏭️ **Step 4:** Create data model diagram
5. ⏭️ **Step 5:** Write SQL queries

---

These relationships form the complete social graph and interaction model for Twitter!
