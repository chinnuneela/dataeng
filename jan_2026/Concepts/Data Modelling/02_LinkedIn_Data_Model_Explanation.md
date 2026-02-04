# LinkedIn Data Model - Basic Level

# Overview
    This is a basic-level model focusing on core features.



## Core Features Modeled

1. User Profiles - Professional profiles with basic information
2. Connections - Professional network (friend connections)
3. Posts - Content sharing and updates
4. Comments - Engagement on posts
5. Likes - Reactions to posts
6. Companies - Organization profiles
7. Work Experience - Job history
8. Education - Academic background
9. Skills - Professional competencies
10.Messages - Direct messaging between users

---

## Entity-Relationship Overview

### Main Entities:
- Users : Platform members
- Companies : Organizations
- Posts : Content shared by users
- Comments : Responses to posts
- Likes : Reactions to posts
- Connections : User-to-user relationships
- Work_Experience : Job history
- Education : Academic credentials
- Skills : Professional competencies
- User_Skills : Junction table (users ↔ skills)
- Messages : Direct messages between users

---

## Detailed Entity Descriptions

### 1. Users Table
        Purpose : Store user profile information

**Attributes**:
- `user_id` (PK): Unique identifier
- `first_name`: User's first name
- `last_name`: User's last name
- `email`: Contact email (unique)
- `password_hash`: Encrypted password
- `headline`: Professional headline (e.g., "Software Engineer at Google")
- `profile_photo_url`: Link to profile picture
- `location`: City, Country
- `about`: Professional summary
- `created_at`: Account creation timestamp
- `updated_at`: Last profile update
- `is_active`: Account status

**Business Rules**:
- Email must be unique
- Email is required for registration
- Users can update their profile anytime

---

### 2. Companies Table
**Purpose**: Store organization information

**Attributes**:
- `company_id` (PK): Unique identifier
- `company_name`: Official company name
- `industry`: Business sector
- `company_size`: Employee count range
- `headquarters`: Location
- `website`: Company website URL
- `description`: About the company
- `logo_url`: Company logo
- `founded_year`: Year established
- `created_at`: Record creation timestamp

**Business Rules**:
- Company name should be unique
- Users can work at multiple companies (over time)

---

### 3. Posts Table
**Purpose**: Store user-generated content

**Attributes**:
- `post_id` (PK): Unique identifier
- `user_id` (FK): Author of the post
- `content`: Post text content
- `image_url`: Optional image attachment
- `video_url`: Optional video attachment
- `created_at`: Post creation time
- `updated_at`: Last edit time
- `is_deleted`: Soft delete flag

**Relationships**:
- One user can create many posts (1:N)
- One post belongs to one user

**Business Rules**:
- Posts can be edited within 24 hours
- Deleted posts are soft-deleted (not removed from DB)

---

### 4. Comments Table
**Purpose**: Store comments on posts

**Attributes**:
- `comment_id` (PK): Unique identifier
- `post_id` (FK): Post being commented on
- `user_id` (FK): Comment author
- `content`: Comment text
- `created_at`: Comment timestamp
- `updated_at`: Last edit time
- `is_deleted`: Soft delete flag

**Relationships**:
- One post can have many comments (1:N)
- One user can write many comments (1:N)

**Business Rules**:
- Comments can be edited
- Users can delete their own comments

---

### 5. Likes Table
**Purpose**: Track post likes/reactions

**Attributes**:
- `like_id` (PK): Unique identifier
- `post_id` (FK): Post being liked
- `user_id` (FK): User who liked
- `created_at`: Like timestamp

**Relationships**:
- One post can have many likes (1:N)
- One user can like many posts (M:N via this table)

**Business Rules**:
- One user can like a post only once
- Users can unlike posts (delete record)

---

### 6. Connections Table
**Purpose**: Manage user-to-user professional connections

**Attributes**:
- `connection_id` (PK): Unique identifier
- `user_id_1` (FK): First user
- `user_id_2` (FK): Second user
- `status`: Connection status (pending, accepted, blocked)
- `requested_at`: Connection request time
- `accepted_at`: Connection acceptance time

**Relationships**:
- Many-to-Many self-referencing relationship

**Business Rules**:
- Connection must be accepted by both parties
- Users cannot connect to themselves
- Duplicate connections prevented by unique constraint

---

### 7. Work_Experience Table
**Purpose**: Store job history

**Attributes**:
- `experience_id` (PK): Unique identifier
- `user_id` (FK): User's profile
- `company_id` (FK): Company worked at
- `job_title`: Position held
- `employment_type`: Full-time, Part-time, Contract, etc.
- `start_date`: Job start date
- `end_date`: Job end date (NULL if current)
- `description`: Job responsibilities
- `is_current`: Currently working here

**Relationships**:
- One user can have many work experiences (1:N)
- One company can have many employees (1:N)

**Business Rules**:
- If `is_current` = TRUE, `end_date` should be NULL
- Start date must be before end date

---

### 8. Education Table
**Purpose**: Store academic credentials

**Attributes**:
- `education_id` (PK): Unique identifier
- `user_id` (FK): User's profile
- `institution_name`: School/University name
- `degree`: Degree type (Bachelor's, Master's, PhD, etc.)
- `field_of_study`: Major/specialization
- `start_year`: Year started
- `end_year`: Year graduated (NULL if ongoing)
- `grade`: GPA or grade
- `description`: Additional details

**Relationships**:
- One user can have multiple education records (1:N)

**Business Rules**:
- Start year must be before end year
- Users can have ongoing education (end_year = NULL)

---

### 9. Skills Table
**Purpose**: Master list of professional skills

**Attributes**:
- `skill_id` (PK): Unique identifier
- `skill_name`: Name of skill (e.g., "Python", "Project Management")
- `category`: Skill category (Technical, Soft Skills, etc.)

**Business Rules**:
- Skill names should be unique
- Centralized skill list for consistency

---

### 10. User_Skills Table (Junction Table)
**Purpose**: Link users to their skills

**Attributes**:
- `user_skill_id` (PK): Unique identifier
- `user_id` (FK): User profile
- `skill_id` (FK): Skill from master list
- `proficiency_level`: Beginner, Intermediate, Expert
- `years_of_experience`: Years using this skill
- `endorsed_count`: Number of endorsements

**Relationships**:
- Many-to-Many relationship between Users and Skills

**Business Rules**:
- One user cannot add same skill twice
- Skills can be endorsed by connections

---

### 11. Messages Table
**Purpose**: Direct messaging between users

**Attributes**:
- `message_id` (PK): Unique identifier
- `sender_id` (FK): User sending message
- `receiver_id` (FK): User receiving message
- `content`: Message text
- `sent_at`: Message timestamp
- `is_read`: Read status
- `read_at`: Time message was read

**Relationships**:
- One user can send many messages (1:N)
- One user can receive many messages (1:N)

**Business Rules**:
- Users can only message their connections
- Messages cannot be edited (only deleted)

---

## Relationships Summary

| Relationship | Type | Description |
|-------------|------|-------------|
| Users → Posts | 1:N | One user creates many posts |
| Users → Comments | 1:N | One user writes many comments |
| Posts → Comments | 1:N | One post has many comments |
| Users → Likes | 1:N | One user likes many posts |
| Posts → Likes | 1:N | One post has many likes |
| Users ↔ Users (Connections) | M:N | Users connect with each other |
| Users → Work_Experience | 1:N | One user has many jobs |
| Companies → Work_Experience | 1:N | One company has many employees |
| Users → Education | 1:N | One user has multiple degrees |
| Users ↔ Skills | M:N | Users have multiple skills |
| Users → Messages (sent) | 1:N | One user sends many messages |
| Users → Messages (received) | 1:N | One user receives many messages |

---

## Key Design Decisions

### 1. Surrogate Keys
- Used auto-incrementing integers for all primary keys
- **Why**: Simpler, more efficient, allows natural keys to change

### 2. Soft Deletes
- Posts and comments use `is_deleted` flag
- **Why**: Preserve data for analytics, allow restoration

### 3. Timestamps
- All tables have `created_at`
- Mutable entities have `updated_at`
- **Why**: Audit trail, debugging, analytics

### 4. Normalization Level
- Mostly 3NF (Third Normal Form)
- **Why**: Balance between data integrity and query performance

### 5. Junction Tables
- User_Skills for M:N relationship
- Connections for self-referencing M:N
- **Why**: Proper normalization, allows relationship attributes

---

## Sample Queries

### Get user's full profile
```sql
SELECT u.*, 
       GROUP_CONCAT(DISTINCT s.skill_name) as skills,
       COUNT(DISTINCT c.connection_id) as connection_count,
       COUNT(DISTINCT p.post_id) as post_count
FROM users u
LEFT JOIN user_skills us ON u.user_id = us.user_id
LEFT JOIN skills s ON us.skill_id = s.skill_id
LEFT JOIN connections c ON (u.user_id = c.user_id_1 OR u.user_id = c.user_id_2)
LEFT JOIN posts p ON u.user_id = p.user_id
WHERE u.user_id = 1
GROUP BY u.user_id;
```

### Get user's connections
```sql
SELECT u2.user_id, u2.first_name, u2.last_name, u2.headline
FROM connections c
JOIN users u2 ON (
    CASE 
        WHEN c.user_id_1 = 1 THEN c.user_id_2 = u2.user_id
        WHEN c.user_id_2 = 1 THEN c.user_id_1 = u2.user_id
    END
)
WHERE (c.user_id_1 = 1 OR c.user_id_2 = 1)
  AND c.status = 'accepted';
```

### Get post with engagement metrics
```sql
SELECT p.*, 
       u.first_name, u.last_name,
       COUNT(DISTINCT l.like_id) as like_count,
       COUNT(DISTINCT c.comment_id) as comment_count
FROM posts p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
WHERE p.post_id = 1
GROUP BY p.post_id;
```

---

## Potential Enhancements (Not in Basic Model)

1. **Notifications**: Alert users of activities
2. **Groups**: Professional communities
3. **Events**: Networking events
4. **Endorsements**: Skill validations
5. **Recommendations**: Written testimonials
6. **Job Postings**: Career opportunities
7. **Hashtags**: Content categorization
8. **Saved Posts**: Bookmark feature
9. **Privacy Settings**: Control visibility
10. **Analytics**: Profile views, post impressions

---

## Scalability Considerations

### For Production System:
1. **Indexing**: Add indexes on foreign keys and frequently queried columns
2. **Partitioning**: Partition large tables (posts, messages) by date
3. **Caching**: Cache user profiles, connection lists
4. **Sharding**: Distribute users across multiple databases
5. **Read Replicas**: Separate read and write operations
6. **CDN**: Store media files (images, videos) externally
7. **Search Engine**: Use Elasticsearch for full-text search
8. **Message Queue**: Handle async operations (notifications, emails)

---

## Next Steps

1. Review the SQL schema file (`linkedin_schema.sql`)
2. Import into https://erd.dbdesigner.net/
3. Visualize the relationships
4. Experiment with sample data
5. Write queries to understand data flow

---

## Conclusion

This basic LinkedIn data model covers:
- ✅ Core social networking features
- ✅ Professional profile management
- ✅ Content creation and engagement
- ✅ Messaging capabilities
- ✅ Proper normalization
- ✅ Scalable foundation

**Remember**: This is a simplified model. Real LinkedIn has hundreds of tables and complex business logic!
