# todolistleap


# Project Presentation: Leap To Do App

#  Project Title: Leap To Do App
#  Objective: A task management app with secure authentication, multiple task views, data visualization, and logout functionality.
#  Presenter: Suleyman
#  Date: June 15, 2025

#  Project Overview

    Problem Statement: Users need a secure, intuitive app to manage and visualize tasks with easy logout.
    Goals:
        Implement authentication with login/logout using BLoC pattern.
        Develop homepage, calendar, and chart views for task management.
        Store tasks in a SQLite database.
#  Design
    Design Concept: Modern UI with blue and white colors, rounded cards, shadows, interactive charts, and consistent drawer for logout.
    Key Features:
        Login/registration screens with input validation.
        Homepage with task list and filters.
        Calendar page with date-based task filtering.
        Chart page with task completion visualization.
        Drawer-based logout across main screens.
#  Login and Logout Functionality
    Description: Built authentication system with login and logout using BLoC, accessible via drawer.
    What I Did:
        Developed AuthBloc to manage login, registration, session checks, and logout events.
        Used SharedPreferences to store email, password, and login status.
        Implemented registration with email uniqueness check and login verification.
        Added logout in CustomDrawer, triggered by LogoutEvent to clear session and redirect to login page.
        Integrated logout option across homepage, calendar, and chart screens.
#  Homepage and Task Management
    Description: Developed a homepage to display and manage tasks, powered by TaskBloc.
    What I Did:
        Created HomePage with task list, date/completion filters, and navigation.
        Used BlocBuilder/BlocListener for dynamic task updates.
        Implemented TaskBloc for CRUD operations (add, edit, delete, toggle completion) and filtering.
        Added swipe-to-delete, task editing, and add task modal.
#  Calendar Page Functionality
    Description: Built a calendar page to filter and manage tasks by date using TableCalendar.
    What I Did:
        Created CalendarScreen with a monthly calendar view and task markers.
        Implemented date selection to filter tasks via TaskBloc.
        Added filter chips for Completed, Not Completed, and All Tasks.
        Supported task deletion (swipe-to-delete with confirmation) and editing.
        Integrated username display and AuthBloc for session management.
#  Chart Page Functionality
    Description: Built a chart page to visualize task completion status using fl_chart.
    What I Did:
        Created ChartScreen with an interactive pie chart showing completed vs. not completed tasks.
        Implemented touch feedback to highlight chart sections with percentage badges.
        Added status indicators for pending/completed tasks with counts and icons.
        Supported adding tasks via modal when no tasks exist.
        Integrated username display and AuthBloc for session management.
#  Database Integration
    Description: Implemented SQLite database to persist tasks using DatabaseHelper.
    What I Did:
        Created DatabaseHelper singleton to manage SQLite database.
        Defined tasks table with fields for id, title, date, time, category, priority, description, and completion.
        Implemented CRUD operations (insert, update, delete, query) for tasks.
        Supported database initialization and schema upgrades.
        Integrated with TaskBloc for task persistence.
# Development Process
    Methodology: Incremental development with focus on authentication, task views, visualization, and logout.
    Steps:
    Set up Flutter project with BLoC architecture.
    Built login/registration with AuthBloc and logout via drawer.
    Developed homepage and TaskBloc for task management.
    Added calendar page for date-based filtering.
    Created chart page for task visualization.
    Integrated SQLite with DatabaseHelper.
#  Tools: Flutter, Dart, SharedPreferences, sqflite, TableCalendar, fl_chart.
#  Conclusion
    Summary: Built a task management app with secure login/logout, multiple task views, and data visualization using Flutter and BLoC.
    Takeaways: Mastered BLoC, SQLite, TableCalendar, fl_chart, and Flutter UI design.
#  References
    Flutter Documentation: https://flutter.dev/docs
    BLoC Library: https://pub.dev/packages/flutter_bloc
    SharedPreferences: https://pub.dev/packages/shared_preferences
    sqflite: https://pub.dev/packages/sqflite
    TableCalendar: https://pub.dev/packages/table_calendar
    fl_chart: https://pub.dev/packages/fl_chart


