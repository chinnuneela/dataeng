# Complete Guide to Data Modelling

## Table of Contents
1. [Introduction to Data Modelling](#introduction)
2. [Why Data Modelling Matters](#why-it-matters)
3. [Types of Data Models](#types-of-data-models)
4. [Data Modelling Concepts](#core-concepts)
5. [Normalization](#normalization)
6. [Relationships](#relationships)
7. [Keys and Constraints](#keys-and-constraints)
8. [Data Modelling Process](#modelling-process)
9. [Best Practices](#best-practices)
10. [Common Patterns](#common-patterns)
11. [Tools and Technologies](#tools)

---

## 1. Introduction to Data Modelling {#introduction}

### What is Data Modelling?

**Data Modelling** is the process of creating a visual representation of a system's data and the relationships between different data entities. It's like creating a blueprint before building a house.

### Key Objectives:
- **Organize data** in a structured, logical way
- **Define relationships** between different data entities
- **Ensure data integrity** and consistency
- **Optimize performance** for queries and operations
- **Document** the system's data architecture

### Real-World Analogy:
Think of data modelling like designing a library system:
- **Books** are entities
- **Authors, Publishers, Members** are related entities
- **Borrowing** is a relationship between Members and Books
- **Rules** (one member can borrow max 5 books) are constraints

---

## 2. Why Data Modelling Matters {#why-it-matters}

### Business Benefits:
1. **Clarity**: Everyone understands what data exists and how it relates
2. **Quality**: Reduces data redundancy and inconsistencies
3. **Efficiency**: Optimizes database performance
4. **Scalability**: Easier to add new features
5. **Maintenance**: Simpler to update and debug

### Technical Benefits:
1. **Data Integrity**: Enforces rules at database level
2. **Query Performance**: Proper indexing and structure
3. **Storage Optimization**: Eliminates redundancy
4. **Documentation**: Self-documenting system architecture
5. **Team Collaboration**: Common understanding across developers

### Cost of Poor Data Modelling:
- ❌ Data inconsistencies and errors
- ❌ Slow query performance
- ❌ Difficult to maintain and extend
- ❌ Wasted storage space
- ❌ Complex application logic to handle data issues

---

## 3. Types of Data Models {#types-of-data-models}

### 3.1 Conceptual Data Model

**Purpose**: High-level business view
**Audience**: Business stakeholders, executives
**Detail Level**: Abstract, no technical details

**Characteristics**:
- Identifies major entities (e.g., Customer, Order, Product)
- Shows high-level relationships
- No attributes or keys
- Technology-agnostic

**Example**:
```
Customer ----places----> Order ----contains----> Product
```

**When to Use**:
- Initial project planning
- Business requirement gathering
- Stakeholder presentations

---

### 3.2 Logical Data Model

**Purpose**: Detailed business view with structure
**Audience**: Business analysts, data architects
**Detail Level**: Detailed, but still technology-agnostic

**Characteristics**:
- Defines all entities and attributes
- Specifies primary and foreign keys
- Shows all relationships with cardinality
- Includes data types (conceptually)
- No physical implementation details

**Example**:
```
Customer
- customer_id (PK)
- first_name
- last_name
- email
- created_date

Order
- order_id (PK)
- customer_id (FK)
- order_date
- total_amount
```

**When to Use**:
- Detailed requirement analysis
- Database design planning
- Cross-platform discussions

---

### 3.3 Physical Data Model

**Purpose**: Implementation-ready database design
**Audience**: Database administrators, developers
**Detail Level**: Complete technical specification

**Characteristics**:
- Specific data types (VARCHAR(255), INT, etc.)
- Indexes and constraints
- Partitioning strategies
- Database-specific features
- Performance optimizations

**Example**:
```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email)
);
```

**When to Use**:
- Database implementation
- Performance tuning
- Migration planning

---

## 4. Data Modelling Concepts {#core-concepts}

### 4.1 Entities

**Definition**: A thing or object in the real world that has independent existence

**Types**:
1. **Strong Entity**: Can exist independently (e.g., Customer, Product)
2. **Weak Entity**: Depends on another entity (e.g., OrderItem depends on Order)

**Naming Conventions**:
- Use singular nouns (Customer, not Customers)
- Clear and descriptive
- Avoid abbreviations unless standard

**Examples**:
- **E-commerce**: Customer, Product, Order, Payment
- **Social Media**: User, Post, Comment, Like
- **Banking**: Account, Transaction, Customer, Branch

---

### 4.2 Attributes

**Definition**: Properties or characteristics of an entity

**Types**:

1. **Simple Attribute**: Cannot be divided (e.g., age, price)
2. **Composite Attribute**: Can be divided (e.g., full_name → first_name + last_name)
3. **Single-Valued**: One value (e.g., date_of_birth)
4. **Multi-Valued**: Multiple values (e.g., phone_numbers)
5. **Derived Attribute**: Calculated from other attributes (e.g., age from date_of_birth)

**Best Practices**:
- Store atomic values (break down composite attributes)
- Avoid storing derived data (calculate on-the-fly)
- Use appropriate data types
- Consider NULL handling

**Example**:
```
Customer Entity:
- customer_id (Simple, Single-valued)
- first_name (Simple, Single-valued)
- last_name (Simple, Single-valued)
- email (Simple, Single-valued)
- phone_numbers (Multi-valued) → Separate table!
- age (Derived from date_of_birth) → Don't store!
```

---

### 4.3 Relationships

**Definition**: Associations between entities

**Cardinality Types**:

1. **One-to-One (1:1)**
   - Example: Person ↔ Passport
   - Each person has one passport, each passport belongs to one person

2. **One-to-Many (1:N)**
   - Example: Customer → Orders
   - One customer can have many orders, each order belongs to one customer

3. **Many-to-Many (M:N)**
   - Example: Students ↔ Courses
   - One student enrolls in many courses, one course has many students
   - **Implementation**: Requires junction/bridge table

**Participation**:
- **Total (Mandatory)**: Every entity must participate (solid line)
- **Partial (Optional)**: Entity may or may not participate (dashed line)

---

## 5. Normalization {#normalization}

### What is Normalization?

**Definition**: Process of organizing data to reduce redundancy and improve data integrity

**Goals**:
- Eliminate redundant data
- Ensure data dependencies make sense
- Reduce anomalies (insert, update, delete)

---

### Normal Forms

#### **1NF (First Normal Form)**

**Rules**:
- Each column contains atomic (indivisible) values
- Each column contains values of single type
- Each column has unique name
- Order doesn't matter

**Example - Violation**:
```
| customer_id | name | phone_numbers |
|-------------|------|---------------|
| 1 | John | 123-456, 789-012 | ❌ Multiple values
```

**Example - Compliant**:
```
| customer_id | name | phone_number |
|-------------|------|--------------|
| 1 | John | 123-456 |
| 1 | John | 789-012 |
```

---

#### **2NF (Second Normal Form)**

**Rules**:
- Must be in 1NF
- No partial dependencies (all non-key attributes depend on entire primary key)

**Example - Violation**:
```
| order_id | product_id | product_name | quantity |
|----------|------------|--------------|----------|
| 1 | 101 | Laptop | 2 |
❌ product_name depends only on product_id, not on (order_id, product_id)
```

**Example - Compliant**:
```
Orders:
| order_id | product_id | quantity |

Products:
| product_id | product_name |
```

---

#### **3NF (Third Normal Form)**

**Rules**:
- Must be in 2NF
- No transitive dependencies (non-key attributes don't depend on other non-key attributes)

**Example - Violation**:
```
| employee_id | department_id | department_name |
|-------------|---------------|-----------------|
| 1 | 10 | Sales |
❌ department_name depends on department_id, not employee_id
```

**Example - Compliant**:
```
Employees:
| employee_id | department_id |

Departments:
| department_id | department_name |
```

---

#### **BCNF (Boyce-Codd Normal Form)**

**Rules**:
- Must be in 3NF
- Every determinant must be a candidate key

**When to Use**: Strict normalization for complex scenarios

---

#### **4NF and 5NF**

**4NF**: Eliminates multi-valued dependencies
**5NF**: Eliminates join dependencies

**Note**: Rarely needed in practice; 3NF is usually sufficient

---

### When to Denormalize?

**Reasons**:
- Performance optimization (reduce joins)
- Read-heavy applications
- Reporting and analytics
- Caching layers

**Trade-offs**:
- ✅ Faster reads
- ❌ Slower writes
- ❌ Data redundancy
- ❌ Update anomalies

---

## 6. Relationships in Detail {#relationships}

### 6.1 One-to-One (1:1)

**Implementation**:
```sql
-- Option 1: Foreign key in either table
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50)
);

CREATE TABLE user_profiles (
    profile_id INT PRIMARY KEY,
    user_id INT UNIQUE,  -- UNIQUE ensures 1:1
    bio TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

**When to Use**:
- Separate sensitive data (e.g., User vs UserCredentials)
- Optional attributes (e.g., User vs UserProfile)
- Performance (split large tables)

---

### 6.2 One-to-Many (1:N)

**Implementation**:
```sql
-- Foreign key in "many" side
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,  -- Foreign key
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

**Most Common Relationship**: ~80% of relationships are 1:N

---

### 6.3 Many-to-Many (M:N)

**Implementation**: Requires junction/bridge table
```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100)
);

-- Junction table
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade VARCHAR(2),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE (student_id, course_id)  -- Prevent duplicate enrollments
);
```

**Junction Table Benefits**:
- Can store relationship attributes (enrollment_date, grade)
- Maintains referential integrity
- Enables efficient queries

---

### 6.4 Self-Referencing Relationships

**Use Case**: Hierarchical data (employees → manager, categories → parent_category)

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    manager_id INT,  -- References same table
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);
```

---

## 7. Keys and Constraints {#keys-and-constraints}

### 7.1 Types of Keys

#### **Primary Key (PK)**
- Uniquely identifies each record
- Cannot be NULL
- Only one per table
- Should be immutable

**Examples**:
```sql
-- Natural key (existing attribute)
customer_email VARCHAR(100) PRIMARY KEY

-- Surrogate key (artificial)
customer_id INT PRIMARY KEY AUTO_INCREMENT

-- Composite key (multiple columns)
PRIMARY KEY (order_id, product_id)
```

**Best Practice**: Use surrogate keys (auto-increment integers) for flexibility

---

#### **Foreign Key (FK)**
- References primary key in another table
- Enforces referential integrity
- Can be NULL (optional relationship)

```sql
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE  -- Delete orders when customer deleted
    ON UPDATE CASCADE  -- Update orders when customer_id changes
```

**Referential Actions**:
- `CASCADE`: Propagate changes
- `SET NULL`: Set to NULL
- `RESTRICT`: Prevent deletion/update
- `NO ACTION`: Similar to RESTRICT

---

#### **Unique Key**
- Ensures uniqueness
- Can be NULL (unlike primary key)
- Multiple unique keys allowed per table

```sql
email VARCHAR(100) UNIQUE,
username VARCHAR(50) UNIQUE
```

---

#### **Candidate Key**
- Could be a primary key
- Uniquely identifies records
- Choose one as primary key, others become alternate keys

---

### 7.2 Constraints

#### **NOT NULL**
```sql
first_name VARCHAR(50) NOT NULL
```

#### **CHECK**
```sql
age INT CHECK (age >= 18),
price DECIMAL(10,2) CHECK (price > 0)
```

#### **DEFAULT**
```sql
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
status VARCHAR(20) DEFAULT 'active'
```

---

## 8. Data Modelling Process {#modelling-process}

### Step-by-Step Approach

#### **Step 1: Requirements Gathering**
- Interview stakeholders
- Understand business processes
- Identify data needs
- Document use cases

**Questions to Ask**:
- What data needs to be stored?
- How will data be used?
- What are the business rules?
- What are the reporting needs?

---

#### **Step 2: Identify Entities**
- List all nouns from requirements
- Group related data
- Determine strong vs weak entities

**Example** (E-commerce):
- Customer, Product, Order, Category, Payment, Review, Shipping

---

#### **Step 3: Define Attributes**
- List properties for each entity
- Determine data types
- Identify required vs optional
- Consider constraints

---

#### **Step 4: Identify Relationships**
- Determine how entities relate
- Define cardinality (1:1, 1:N, M:N)
- Specify participation (mandatory/optional)

---

#### **Step 5: Normalize**
- Apply normalization rules
- Eliminate redundancy
- Ensure data integrity

---

#### **Step 6: Add Keys and Constraints**
- Define primary keys
- Add foreign keys
- Set up unique constraints
- Add business rules (CHECK constraints)

---

#### **Step 7: Review and Refine**
- Validate with stakeholders
- Check for missing entities/relationships
- Optimize for performance
- Document decisions

---

## 9. Best Practices {#best-practices}

### Naming Conventions

**Tables**:
- Use plural nouns: `customers`, `orders`, `products`
- Or singular: `customer`, `order`, `product` (be consistent!)
- Lowercase with underscores: `order_items`

**Columns**:
- Descriptive names: `first_name` not `fn`
- Lowercase with underscores: `created_at`
- Avoid reserved words
- Prefix foreign keys: `customer_id`, `product_id`

**Indexes**:
- `idx_tablename_columnname`: `idx_customers_email`

**Constraints**:
- `fk_childtable_parenttable`: `fk_orders_customers`
- `uk_tablename_columnname`: `uk_users_email`

---

### Design Principles

1. **KISS (Keep It Simple, Stupid)**
   - Don't over-engineer
   - Start simple, add complexity as needed

2. **DRY (Don't Repeat Yourself)**
   - Eliminate redundancy
   - Single source of truth

3. **YAGNI (You Aren't Gonna Need It)**
   - Don't add features "just in case"
   - Design for current requirements

4. **Plan for Change**
   - Use surrogate keys
   - Avoid hard-coding values
   - Document assumptions

---

### Performance Considerations

1. **Indexing**:
   - Index foreign keys
   - Index frequently queried columns
   - Don't over-index (slows writes)

2. **Partitioning**:
   - Split large tables by date, region, etc.
   - Improves query performance

3. **Denormalization (when needed)**:
   - For read-heavy workloads
   - Reporting tables
   - Caching layers

4. **Data Types**:
   - Use appropriate sizes (VARCHAR(50) vs VARCHAR(255))
   - INT vs BIGINT based on expected values
   - Consider storage and performance

---

## 10. Common Patterns {#common-patterns}

### 10.1 Audit Trail Pattern

**Purpose**: Track who changed what and when

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL
);
```

---

### 10.2 Soft Delete Pattern

**Purpose**: Mark records as deleted instead of removing them

```sql
is_deleted BOOLEAN DEFAULT FALSE,
deleted_at TIMESTAMP NULL
```

**Queries**:
```sql
-- Active records only
SELECT * FROM products WHERE is_deleted = FALSE;
```

---

### 10.3 Versioning Pattern

**Purpose**: Keep history of changes

```sql
CREATE TABLE product_versions (
    version_id INT PRIMARY KEY,
    product_id INT,
    name VARCHAR(100),
    price DECIMAL(10,2),
    version_number INT,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP,
    is_current BOOLEAN
);
```

---

### 10.4 Polymorphic Association

**Purpose**: One entity relates to multiple entity types

```sql
CREATE TABLE comments (
    comment_id INT PRIMARY KEY,
    commentable_type VARCHAR(50),  -- 'Post', 'Photo', 'Video'
    commentable_id INT,
    content TEXT
);
```

**Note**: Harder to enforce referential integrity

---

## 11. Tools and Technologies {#tools}

### ERD Tools

1. **dbdiagram.io** - Simple, code-based
2. **erd.dbdesigner.net** - Visual, web-based
3. **Lucidchart** - Professional diagramming
4. **MySQL Workbench** - Database-specific
5. **draw.io** - Free, versatile

### Database Design Tools

1. **Vertabelo** - Online database modeler
2. **SQL Designer** - Open-source
3. **pgModeler** - PostgreSQL specific
4. **ERwin** - Enterprise-level

### Documentation

1. **Confluence** - Team wikis
2. **Notion** - Modern documentation
3. **GitHub/GitLab** - Version-controlled docs
4. **Markdown** - Simple, portable

---

## Summary

Data modelling is both an **art and a science**:
- **Science**: Follow normalization rules, best practices
- **Art**: Balance theory with practical needs

**Key Takeaways**:
1. Start with business requirements
2. Model entities and relationships clearly
3. Normalize to reduce redundancy
4. Add constraints for data integrity
5. Optimize for your specific use case
6. Document everything
7. Iterate and refine

**Remember**: A good data model is:
- ✅ Clear and understandable
- ✅ Flexible for future changes
- ✅ Performant for common queries
- ✅ Maintainable by the team
- ✅ Well-documented

---

## Further Reading

- **Books**:
  - "Database Design for Mere Mortals" by Michael J. Hernandez
  - "The Data Warehouse Toolkit" by Ralph Kimball
  
- **Online Resources**:
  - SQL Style Guide: https://www.sqlstyle.guide/
  - Database Normalization: https://www.guru99.com/database-normalization.html

- **Practice**:
  - Model real-world systems (library, hospital, e-commerce)
  - Review open-source database schemas
  - Participate in code reviews
