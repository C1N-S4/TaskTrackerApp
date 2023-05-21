import tkinter as tk
from tkinter import messagebox, ttk
from datetime import datetime
import threading
import json

class Task:
    def __init__(self, name, start_date, deadline):
        self.name = name
        self.start_date = start_date
        self.deadline = deadline

class TaskTrackerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Task Tracker")

        self.task_list = []
        self.load_tasks()  # Kaydedilmiş görevleri yükle

        self.task_name_label = tk.Label(root, text="Task Name:")
        self.task_name_label.pack()

        self.task_name_entry = tk.Entry(root)
        self.task_name_entry.pack()
        self.task_name_entry.bind("<Return>", self.add_task)  # Enter tuşuna basıldığında görev ekle

        self.start_date_label = tk.Label(root, text="Start Date:")
        self.start_date_label.pack()

        self.start_date_entry = tk.Entry(root)
        self.start_date_entry.pack()

        self.deadline_label = tk.Label(root, text="Deadline:")
        self.deadline_label.pack()

        self.deadline_entry = tk.Entry(root)
        self.deadline_entry.pack()

        self.add_button = tk.Button(root, text="Add Task", command=self.add_task)
        self.add_button.pack()

        self.task_tree = ttk.Treeview(root, columns=("Name", "Start Date", "Deadline"))
        self.task_tree.heading("#0", text="ID")
        self.task_tree.heading("Name", text="Task Name")
        self.task_tree.heading("Start Date", text="Start Date")
        self.task_tree.heading("Deadline", text="Deadline")
        self.task_tree.pack()

        self.task_tree.bind("<Double-1>", self.delete_task)  # Çift tıklama ile görevi sil

        self.check_deadlines()

        self.root.protocol("WM_DELETE_WINDOW", self.save_tasks)  # Pencere kapatıldığında görevleri kaydet

    def add_task(self, event=None):
        name = self.task_name_entry.get()
        start_date = self.start_date_entry.get()
        deadline = self.deadline_entry.get()

        if name and start_date and deadline:
            task = Task(name, start_date, deadline)
            self.task_list.append(task)
            self.task_tree.insert("", "end", text=str(len(self.task_list)), values=(task.name, task.start_date, task.deadline))

            self.task_name_entry.delete(0, "end")
            self.start_date_entry.delete(0, "end")
            self.deadline_entry.delete(0, "end")
        else:
            messagebox.showwarning("Error", "Please enter task name, start date, and deadline.")

    def delete_task(self, event):
        selected_item = self.task_tree.selection()
        if selected_item:
            confirmed = messagebox.askyesno("Confirm", "Are you sure you want to delete the task?")
            if confirmed:
                item_text = self.task_tree.item(selected_item)["values"]
                task_name = item_text[0]
                for task in self.task_list:
                    if task.name == task_name:
                        self.task_list.remove(task)
                        self.task_tree.delete(selected_item)
                        break

    def check_deadlines(self):
        threading.Timer(60, self.check_deadlines).start()  # Her 1 dakikada bir kontrol yapmak için timer ayarlanır
        now = datetime.now()

        for task in self.task_list:
            deadline = datetime.strptime(task.deadline, "%m/%d/%Y")  # Deadline'ı datetime nesnesine dönüştürür

            if now >= deadline:
                messagebox.showinfo("Reminder", f"The deadline for task '{task.name}' has passed!")

    def save_tasks(self):
        with open("tasks.json", "w") as file:
            json.dump([task.__dict__ for task in self.task_list], file)

        self.root.destroy()

    def load_tasks(self):
        try:
            with open("tasks.json", "r") as file:
                data = json.load(file)
                self.task_list = [Task(task["name"], task["start_date"], task["deadline"]) for task in data]
                for i, task in enumerate(self.task_list, start=1):
                    self.task_tree.insert("", "end", text=str(i), values=(task.name, task.start_date, task.deadline))
        except FileNotFoundError:
            pass

if __name__ == "__main__":
    root = tk.Tk()
    app = TaskTrackerApp(root)
    root.mainloop()
