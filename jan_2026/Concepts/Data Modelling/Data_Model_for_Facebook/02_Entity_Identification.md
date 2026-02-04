# Step 2: Entity Identification and Explanation - Facebook

## Facebook Entities - Complete List

### Core Entities (15 total):

1. **users** - Platform members
2. **friendships** - Bidirectional friend connections
3. **friend_requests** - Pending friend requests
4. **posts** - User/group/page content
5. **reactions** - Post reactions (6 types)
6. **comments** - Post comments (nested)
7. **shares** - Post shares
8. **groups** - Communities
9. **group_members** - Group membership with roles
10. **pages** - Business/brand pages
11. **page_followers** - Page followers
12. **events** - Social events
13. **event_attendees** - Event RSVPs
14. **photos** - Photo uploads
15. **photo_albums** - Photo collections
16. **photo_tags** - People tagged in photos
17. **messages** - Direct messages
18. **conversations** - Message threads
19. **conversation_participants** - Conversation members
20. **notifications** - Activity alerts

---

## Detailed Entity Analysis

### Entity 1: USERS

**Purpose:** Store user profiles and account information

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| user_id | INT (PK) | Unique identifier |
| email | VARCHAR(100) | Login email (unique) |
| password_hash | VARCHAR(255) | Encrypted password |
| first_name | VARCHAR(50) | First name |
| last_name | VARCHAR(50) | Last name |
| username | VARCHAR(50) | Optional username |
| date_of_birth | DATE | Birth date (13+ required) |
| gender | ENUM | Male, Female, Custom |
| profile_picture_url | VARCHAR(500) | Profile photo |
| cover_photo_url | VARCHAR(500) | Cover image |
| bio | TEXT | About section |
| location | VARCHAR(100) | Current city |
| hometown | VARCHAR(100) | Hometown |
| relationship_status | ENUM | Single, In a relationship, Married, etc. |
| created_at | TIMESTAMP | Account creation |
| is_active | BOOLEAN | Account status |
| is_verified | BOOLEAN | Verification badge |
| friends_count | INT | Number of friends (denormalized) |

**Business Rules:**
- Email must be unique
- Must be 13+ years old
- Profile can be public or private

---

### Entity 2: FRIENDSHIPS

**Purpose:** Track bidirectional friend connections

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| friendship_id | INT (PK) | Unique identifier |
| user_id_1 | INT (FK) | First user |
| user_id_2 | INT (FK) | Second user |
| created_at | TIMESTAMP | Friendship date |

**Business Rules:**
- Bidirectional (mutual friendship)
- No duplicates
- Cannot be friends with yourself
- Requires accepted friend request

---

### Entity 3: FRIEND_REQUESTS

**Purpose:** Manage pending friend requests

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| request_id | INT (PK) | Unique identifier |
| sender_id | INT (FK) | User sending request |
| receiver_id | INT (FK) | User receiving request |
| status | ENUM | pending, accepted, rejected |
| requested_at | TIMESTAMP | Request time |
| responded_at | TIMESTAMP | Response time |

**Business Rules:**
- One pending request per user pair
- Accepted request creates friendship
- Rejected request can be sent again later

---

### Entity 4: POSTS

**Purpose:** Store all user-generated content

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| post_id | BIGINT (PK) | Unique identifier |
| user_id | INT (FK) | Post author |
| group_id | INT (FK) | If posted in group |
| page_id | INT (FK) | If posted on page |
| content | TEXT | Post text |
| post_type | ENUM | status, photo, video, link, share |
| privacy_level | ENUM | public, friends, custom |
| location | VARCHAR(100) | Check-in location |
| feeling | VARCHAR(50) | Feeling/activity |
| created_at | TIMESTAMP | Post time |
| updated_at | TIMESTAMP | Last edit |
| is_deleted | BOOLEAN | Soft delete |
| reactions_count | INT | Total reactions |
| comments_count | INT | Total comments |
| shares_count | INT | Total shares |

**Business Rules:**
- Must belong to user, group, or page
- Privacy settings control visibility
- Can tag multiple users

---

### Entity 5: REACTIONS

**Purpose:** Track post reactions (6 types)

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| reaction_id | BIGINT (PK) | Unique identifier |
| user_id | INT (FK) | User reacting |
| post_id | BIGINT (FK) | Post being reacted to |
| reaction_type | ENUM | like, love, haha, wow, sad, angry |
| created_at | TIMESTAMP | Reaction time |

**Business Rules:**
- One reaction per user per post
- Can change reaction type
- Removing reaction deletes record

**Reaction Types:**
- 👍 Like
- ❤️ Love
- 😂 Haha
- 😮 Wow
- 😢 Sad
- 😠 Angry

---

### Entity 6: COMMENTS

**Purpose:** Store comments and replies (nested)

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| comment_id | BIGINT (PK) | Unique identifier |
| post_id | BIGINT (FK) | Post being commented on |
| user_id | INT (FK) | Comment author |
| parent_comment_id | BIGINT (FK) | Parent comment if reply |
| content | TEXT | Comment text |
| created_at | TIMESTAMP | Comment time |
| updated_at | TIMESTAMP | Last edit |
| is_deleted | BOOLEAN | Soft delete |
| reactions_count | INT | Comment reactions |

**Business Rules:**
- Can be top-level or reply
- Self-referencing for threading
- Can have reactions too

---

### Entity 7: GROUPS

**Purpose:** Communities and interest-based groups

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| group_id | INT (PK) | Unique identifier |
| name | VARCHAR(200) | Group name |
| description | TEXT | Group description |
| privacy_type | ENUM | public, private, secret |
| created_by | INT (FK) | Creator user |
| cover_photo_url | VARCHAR(500) | Group cover |
| created_at | TIMESTAMP | Creation time |
| members_count | INT | Member count |

**Business Rules:**
- Public: Anyone can see and join
- Private: Anyone can see, request to join
- Secret: Invite-only, hidden from search

---

### Entity 8: GROUP_MEMBERS

**Purpose:** Group membership with roles

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| membership_id | INT (PK) | Unique identifier |
| group_id | INT (FK) | Group |
| user_id | INT (FK) | Member |
| role | ENUM | admin, moderator, member |
| joined_at | TIMESTAMP | Join time |

**Business Rules:**
- One membership per user per group
- Admins can manage group
- Moderators can moderate content

---

### Entity 9: PAGES

**Purpose:** Business and brand pages

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| page_id | INT (PK) | Unique identifier |
| name | VARCHAR(200) | Page name |
| category | VARCHAR(100) | Business category |
| description | TEXT | About page |
| profile_picture_url | VARCHAR(500) | Page profile |
| cover_photo_url | VARCHAR(500) | Page cover |
| website | VARCHAR(200) | External link |
| created_at | TIMESTAMP | Creation time |
| followers_count | INT | Follower count |

---

### Entity 10: EVENTS

**Purpose:** Social events and gatherings

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| event_id | INT (PK) | Unique identifier |
| name | VARCHAR(200) | Event name |
| description | TEXT | Event details |
| location | VARCHAR(200) | Event location |
| start_time | DATETIME | Event start |
| end_time | DATETIME | Event end |
| created_by | INT (FK) | Creator |
| group_id | INT (FK) | If group event |
| page_id | INT (FK) | If page event |
| privacy_type | ENUM | public, private |
| cover_photo_url | VARCHAR(500) | Event image |
| created_at | TIMESTAMP | Creation time |

---

### Entity 11: EVENT_ATTENDEES

**Purpose:** Event RSVPs

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| attendee_id | INT (PK) | Unique identifier |
| event_id | INT (FK) | Event |
| user_id | INT (FK) | User |
| rsvp_status | ENUM | going, interested, not_going |
| responded_at | TIMESTAMP | RSVP time |

---

### Entity 12: PHOTO_ALBUMS

**Purpose:** Photo collections

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| album_id | INT (PK) | Unique identifier |
| user_id | INT (FK) | Album owner |
| name | VARCHAR(200) | Album name |
| description | TEXT | Album description |
| privacy_level | ENUM | public, friends, custom |
| created_at | TIMESTAMP | Creation time |
| photos_count | INT | Photo count |

---

### Entity 13: PHOTOS

**Purpose:** Individual photos

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| photo_id | BIGINT (PK) | Unique identifier |
| user_id | INT (FK) | Uploader |
| album_id | INT (FK) | Album (optional) |
| post_id | BIGINT (FK) | If part of post |
| photo_url | VARCHAR(500) | Image URL |
| caption | TEXT | Photo caption |
| created_at | TIMESTAMP | Upload time |

---

### Entity 14: PHOTO_TAGS

**Purpose:** People tagged in photos

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| tag_id | BIGINT (PK) | Unique identifier |
| photo_id | BIGINT (FK) | Photo |
| user_id | INT (FK) | Tagged user |
| created_at | TIMESTAMP | Tag time |

---

### Entity 15: CONVERSATIONS

**Purpose:** Message threads

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| conversation_id | BIGINT (PK) | Unique identifier |
| is_group_chat | BOOLEAN | Group vs 1-on-1 |
| name | VARCHAR(200) | Chat name (optional) |
| created_at | TIMESTAMP | Creation time |

---

### Entity 16: CONVERSATION_PARTICIPANTS

**Purpose:** Users in conversations

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| participant_id | BIGINT (PK) | Unique identifier |
| conversation_id | BIGINT (FK) | Conversation |
| user_id | INT (FK) | Participant |
| joined_at | TIMESTAMP | Join time |

---

### Entity 17: MESSAGES

**Purpose:** Individual messages

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| message_id | BIGINT (PK) | Unique identifier |
| conversation_id | BIGINT (FK) | Conversation |
| sender_id | INT (FK) | Sender |
| content | TEXT | Message text |
| sent_at | TIMESTAMP | Send time |
| is_read | BOOLEAN | Read status |

---

### Entity 18: NOTIFICATIONS

**Purpose:** Activity alerts

**Attributes:**

| Attribute | Data Type | Description |
|-----------|-----------|-------------|
| notification_id | BIGINT (PK) | Unique identifier |
| user_id | INT (FK) | Recipient |
| type | ENUM | friend_request, post_reaction, comment, etc. |
| actor_user_id | INT (FK) | Who triggered |
| related_id | BIGINT | Related entity ID |
| is_read | BOOLEAN | Read status |
| created_at | TIMESTAMP | Notification time |

---

## Entity Summary

| Entity | Type | Purpose |
|--------|------|---------|
| users | Core | User profiles |
| friendships | Junction | Bidirectional friends |
| friend_requests | Supporting | Pending requests |
| posts | Core | Content |
| reactions | Junction | Engagement |
| comments | Core | Discussion |
| groups | Core | Communities |
| group_members | Junction | Membership |
| pages | Core | Business presence |
| page_followers | Junction | Page followers |
| events | Core | Social events |
| event_attendees | Junction | RSVPs |
| photo_albums | Core | Photo collections |
| photos | Core | Images |
| photo_tags | Junction | Photo tagging |
| conversations | Core | Message threads |
| conversation_participants | Junction | Chat members |
| messages | Core | Messages |
| notifications | Supporting | Alerts |

---

## Next Steps

1. ✅ Step 1: Problem diagnosis
2. ✅ Step 2: Entity identification (CURRENT)
3. ⏭️ Step 3: Establish relationships
4. ⏭️ Step 4: Create data model diagram
5. ⏭️ Step 5: Write SQL queries

---

These 18+ entities form the complete foundation for our Facebook data model!
