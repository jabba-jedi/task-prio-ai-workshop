# Task Prioritizer Workshop

A laid-back office hours workshop demonstrating modern development workflows with AI tooling, held at PandaDoc R&D in October 2025.

## Workshop Overview

This repository contains a simple **Task Prioritizer** app built to demonstrate four key development practices:

1. **Spec-Driven Development** with [Spec Kit](https://github.com/github/spec-kit)
2. **LLM Integration** for intelligent data transformation (using Gemini)
3. **Database Persistence** with Supabase
4. **End-to-End Testing** with Playwright

The goal isn't to build a complex application—it's to show how these tools work together in a real workflow that you can repeat and adapt for your own projects.

---

## What We're Building

A minimal web app where you:
- Enter a work task (e.g., "Fix the bug in the login form")
- See your original input alongside AI-generated analysis
- Watch the data get logged to Supabase
- Test it all with Playwright

**Key insight:** The side-by-side display proves the AI is actually processing your input—not just doing regex tricks or showing random outputs.

---

## Workshop Structure

### Part 1: Spec-Driven Development with Spec Kit

Learn how to define features using specifications instead of immediately jumping into code.

[![Spec Kit Video Overview](https://img.youtube.com/vi/a9eR1xsfvHg/0.jpg)](https://www.youtube.com/watch?v=a9eR1xsfvHg)

**What is Spec-Driven Development?**

Instead of "vibe coding" features from scratch, Spec Kit helps you:
- Define **what** you want to build (specifications)
- Plan **how** to build it (implementation plan)
- Generate **tasks** and execute them systematically

We'll use Spec Kit to build the initial app in two passes:
- **Pass 1A:** UI scaffold with hardcoded data
- **Pass 1B:** Real Gemini API integration

Resources:
- [Spec Kit Repository](https://github.com/github/spec-kit)
- [Spec Kit Documentation](https://github.com/github/spec-kit#-what-is-spec-driven-development)

---

### Part 2: Testing with Playwright

Before adding more features, we'll write Playwright tests to verify:
- User can type and submit tasks
- Both original and AI-analyzed text appear on the page
- The transformation is consistent and verifiable

This proves the app works and gives us confidence to add complexity.

---

### Part 3: Adding Supabase with Spec Kit

Using Spec Kit again, we'll add persistence:
- Create a Supabase table schema
- Log each task submission (original text + AI analysis)
- Update our Playwright tests to verify data reaches the database

This demonstrates how Spec Kit handles iterative feature additions on existing code.

---

## Why This Matters

This workshop shows a **realistic development flow**:
1. Start simple (hardcoded data)
2. Add real functionality (AI integration)
3. Test it (Playwright)
4. Extend it (database persistence)
5. Test again

All while using AI tooling (Cursor + Spec Kit) to write most of the code for us.

---

## Prerequisites

To follow along, you'll need:
- [Node.js](https://nodejs.org/) (v18+)
- [Cursor](https://cursor.sh/) or another AI coding assistant
- [Spec Kit](https://github.com/github/spec-kit) installed (`uv tool install specify-cli --from git+https://github.com/github/spec-kit.git`)
- A [Gemini API key](https://ai.google.dev/)
- A [Supabase account](https://supabase.com/) (free tier is fine)

---

## Getting Started

1. Clone this repository
2. Install dependencies: `npm install`
3. Copy `.env.example` to `.env` and add your Gemini API key
4. Run the dev server: `npm run dev`
5. Open `http://localhost:5173`

---

## Workshop Notes

This is an **office hours style workshop**—casual, hands-on, and focused on learning by doing. Feel free to:
- Ask questions as we go
- Experiment with different task inputs
- Try modifying the specs and seeing what happens
- Break things (that's how we learn!)

---

## About

**Workshop Date:** October 2025  
**Location:** PandaDoc R&D  
**Format:** Laid-back office hours session

Questions or suggestions? Open an issue or reach out!

---

## License

MIT License - feel free to use this as a starting point for your own workshops or projects.
