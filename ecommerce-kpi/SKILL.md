---

name: ecommerce-kpi
description: Enterprise Multi-Channel Ecommerce KPI Management System
---------------------------------------------------------------------

# Ecommerce KPI Management System

## Project Overview

Enterprise system for monitoring employee performance across multiple ecommerce platforms.

Main Goals:

* Track employee activities.
* Monitor business performance.
* Calculate KPI automatically.
* Calculate rewards automatically.
* Manage blacklist customers.
* Generate daily reports.
* Provide centralized management through Web Admin and Boss Mobile App.

---

# Users

## Employees

Use:

* Chrome Extension

Platforms:

* Shopee Seller Center
* Lazada Seller Center
* TikTok Shop Seller Center
* Tiki Seller Center

Employees do NOT have:

* Employee Mobile App
* Employee Web Portal

---

## Managers / Business Owners

Use:

* Flutter Boss App

Functions:

* Revenue Monitoring
* KPI Monitoring
* Reward Monitoring
* Blacklist Monitoring
* Reports Monitoring

---

## Administrators

Use:

* Web Admin

Functions:

* Employee Management
* KPI Configuration
* Reward Configuration
* Blacklist Management
* System Configuration
* Reporting

---

# System Architecture

Chrome Extension
→ FastAPI Backend
→ MongoDB Community Server

Web Admin
→ FastAPI Backend

Flutter Boss App
→ FastAPI Backend

FastAPI Backend
→ Email Report Service

---

# Database

Engine:

MongoDB Community Server

Management Tool:

MongoDB Compass

Connection:

mongodb://localhost:27017

Database Name:

ecommerce_kpi_system

---

# Technology Stack

## Backend

* Python 3.12+
* FastAPI
* Motor
* Pydantic V2
* JWT Authentication

Architecture:

* Clean Architecture
* Repository Pattern
* Service Layer
* Dependency Injection

---

## Database

* MongoDB Community Server
* MongoDB Compass

---

## Web Admin

* NextJS
* TypeScript
* TailwindCSS

---

## Mobile

* Flutter
* Riverpod
* Dio
* GoRouter

---

## Chrome Extension

* Manifest V3
* TypeScript

---

# Data Collection Rules

Preferred Methods:

1. Fetch Interception
2. XHR Interception

Avoid:

* HTML Scraping
* DOM Parsing

Use DOM Scraping only when API interception is impossible.

Sync Interval:

Every 1 Hour

---

# Database Collections

employees

employee_sessions

orders

chats

products

revenues

kpi_daily

rewards

customer_blacklist

notifications

reports

settings

---

# Employee Data

Collect:

* Employee ID
* Employee Name
* Working Platform

Platforms:

* Shopee
* Lazada
* TikTok Shop
* Tiki

---

# Orders Data

Collect:

* Order ID
* Order Status
* Completed Orders
* Cancelled Orders
* Returned Orders
* Late Orders

---

# Chat Data

Collect:

* Chat Count
* Response Rate
* Average Response Time

---

# Product Data

Collect:

* New Products
* Updated Products

---

# Revenue Data

Collect:

* Daily Revenue
* Monthly Revenue
* Total Orders
* Successful Orders
* Returned Orders
* Cancelled Orders

---

# Order Ownership Rule

Every order belongs to:

The employee who confirmed the order.

KPI calculations must use:

confirmed_by employee

---

# KPI Rules

Total KPI = 100 Points

Orders = 40 Points

Chats = 20 Points

Products = 15 Points

Revenue = 25 Points

---

# Order KPI Formula

Order Score:

## (Completed Orders × 1)

## (Cancelled Orders × 3)

(Late Orders × 2)

Maximum:

40 Points

---

# Chat KPI Formula

Response Rate >= 95%

= 10 Points

Response Time <= 1 Minute

= 10 Points

Maximum:

20 Points

---

# Product KPI Formula

1 New Product

= 1 Point

5 Product Updates

= 1 Point

Maximum:

15 Points

---

# Revenue KPI Formula

(Actual Revenue / Target Revenue) × 25

Maximum:

25 Points

---

# Penalty Rules

Cancel Order

= -3

Late Order

= -2

Customer Complaint

= -5

One Star Review

= -2

Product Violation

= -10

---

# KPI Classification

KPI >= 90

Excellent

---

KPI 80 - 89

Good

---

KPI 70 - 79

Fair

---

KPI 60 - 69

Pass

---

KPI < 60

Failed

---

# Reward Rules

KPI >= 90

Reward:

2,000,000 VND

---

KPI 80 - 89

Reward:

1,000,000 VND

---

KPI 70 - 79

Reward:

500,000 VND

---

KPI < 70

Reward:

0 VND

---

# Blacklist Rules

Customer enters blacklist if:

Cancelled Orders >= 3

OR

Returned Orders >= 5

Risk Levels:

* Low
* Medium
* High
* Blacklist

Collection:

customer_blacklist

---

# Daily Email Report

Run Time:

23:59 Daily

Contents:

* Daily Revenue
* Total Orders
* KPI Summary
* Reward Summary
* Top Employees
* New Blacklist Customers

Recipients:

Business Owner
Managers

---

# API Requirements

All APIs must:

* Use JWT Authentication
* Use Pydantic Validation
* Return Standard Response Format
* Support Pagination
* Support Filtering
* Support Sorting

---

# Security Requirements

* JWT Authentication
* Password Hashing
* Role Based Access Control
* Secure API Endpoints

Roles:

* Admin
* Manager
* Employee

---

# AI Policy

Current MVP:

NO AI
NO Machine Learning

Future AI Features:

* Customer Risk Prediction
* KPI Prediction
* Revenue Forecast

Only after collecting real business data.

---

# Development Rules

Always Generate:

* Production Ready Code
* Type Safe Code
* Modular Code
* Scalable Code
* Clean Architecture

Use:

* Repository Pattern
* Service Layer
* Dependency Injection

Never Generate:

* Demo Architecture
* Toy Examples
* Fake Services
* Mock Database
* Atlas Configuration

Always Assume:

MongoDB Community Server
MongoDB Compass
Local Development Environment
