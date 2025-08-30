import toga
from toga.style import Pack
from toga.style.pack import COLUMN, CENTER


class HelloWorld(toga.App):
    def startup(self):
        main_box = toga.Box(style=Pack(direction=COLUMN, alignment=CENTER, padding=20))

        label = toga.Label("Hello, Android!", style=Pack(padding=10))
        main_box.add(label)

        self.main_window = toga.MainWindow(title=self.formal_name)
        self.main_window.content = main_box
        self.main_window.show()


def main():
    return HelloWorld()

