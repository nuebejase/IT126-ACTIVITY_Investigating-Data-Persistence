# IT 126 – Module 3, Lesson 2 Activity: Investigating Data Persistence

## Analysis

**1. What happened to the task titles when you added them to the list?**

Each time **Add** was pressed, `_addTask()` took the text from the field, trimmed it, and (if it
was not empty) appended it to the `_tasks` list inside `setState`. The title became a `String`
object stored in the list in memory, and the screen then showed it as a new numbered row, with
the counter going from 0 to 3 after three tasks. Empty and whitespace-only titles were skipped,
so they were never added.

**2. Why could the application display the tasks while it was running?**

While the app is running, the `_tasks` list is a live object in the process's memory (RAM),
owned by the screen's `State` object. Calling `setState` tells Flutter to rebuild the widget,
and the `build` method reads `_tasks` and creates one `ListTile` per item. As long as the process
is alive and the `State` object still exists, the data is available to be read, and memory is
fast, so the UI updates instantly.

**3. What happened after the application process ended and the application was relaunched?**

The list was empty. The app showed "No tasks yet" and "Tasks in memory: 0", and the session start
time in the footer had changed, showing it was a new session. When the process ended, the memory
holding the old `State` object and its list was released. On relaunch a new `State` was created
and `_tasks` was initialised to an empty list again, and nothing was available to restore the old
data from.

**4. Would keeping the list inside a `StatefulWidget` automatically make the tasks persistent? Explain your answer.**

No. The `List<String>` in this app is already inside a `StatefulWidget`'s `State`, and the tasks
still disappeared after relaunch. A `StatefulWidget` keeps its state alive across *rebuilds* while
the widget stays in the widget tree, but that state is still ordinary in-memory objects. It is
discarded when the widget is removed from the tree, and it is certainly lost when the process is
terminated (by the user, or by the operating system to reclaim memory). Widget state is a way to
manage *temporary UI data during a session*; it is not a durable record of application data.
Persistence requires writing the data somewhere that outlives the process.

**5. What would the application need to do to preserve the tasks between sessions?**

It would need to save each task to persistent storage (such as a file, a key-value store, or a
local database like SQLite through `sqflite`) at the moment it is added, and load the saved
tasks back when the app starts (for example in `initState`) before displaying them. Updating or
deleting a task would also have to change the stored record, not only the on-screen list. Because
reading and writing storage is asynchronous, the UI would also have to handle waiting (using
`async`/`await`), refreshing the list after a change, and errors when a write fails. For
structured, searchable records like tasks, a local SQLite table with an auto-generated `id`, a
`title`, and an `is_completed` column would be a good fit.

**6. If the application eventually stored hundreds or thousands of tasks, what problems might arise from managing all the data manually in memory?**

- **Nothing survives:** all of the data is still lost whenever the process ends, and the more
  data there is, the more is lost.
- **Memory use:** every task would be kept in RAM at the same time, whether or not it is on screen.
- **Manual searching and filtering:** finding, sorting, or filtering tasks (for example "only
  pending ones") would mean writing and maintaining loops over the whole list by hand.
- **No reliable identity:** a `List<String>` identifies a task only by its position or its text.
  Positions shift when items are removed, and titles can repeat, so it becomes hard to update or
  delete exactly the right one.
- **No structure:** a plain string cannot hold extra information such as a description, due date,
  priority, or completion status without redesigning the data.
- **Manual persistence is fragile:** if I tried to save the list myself, for example by rewriting
  one big file after every change, I would also have to handle partial writes, corrupted data,
  and loading speed, and I would have no constraints or transactions to protect the data.

**7. How could separating the operations that save and retrieve tasks from the UI make the application easier to maintain?**

If the code that saves and retrieves tasks lives in its own class (for example a repository with
methods like `create`, `getAll`, `markCompleted`, and `delete`), the screen only asks for what it
needs ("give me the tasks", "add this task") and does not know how or where they are stored. This
helps in several ways:

- **One place to change:** moving from an in-memory list to SQLite, or adding a new column, is
  changed inside the repository without rewriting every widget.
- **No duplicated logic:** several screens can share the same data-access code instead of each
  repeating its own.
- **Simpler UI code:** widgets stay focused on displaying data and handling user input.
- **Easier testing:** the UI can be tested with a fake repository, and the storage code can be
  tested without any UI.

