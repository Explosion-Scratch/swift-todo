import SwiftUI

enum Priority: String, Identifiable, CaseIterable {
    var id: UUID {
        return UUID()
    }
    
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

extension Priority {
    var title: String {
        switch self {
            case .low:
                return "Low"
            case .medium:
                return "Medium"
            case .high:
                return "High"
        }
    }
}

// https://stackoverflow.com/questions/58419161
struct NiceButtonStyle: ButtonStyle {
  var foregroundColor: Color
  var backgroundColor: Color
  var pressedColor: Color

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .font(.headline)
      .frame(maxWidth: .infinity)
      .padding(10)
      .foregroundColor(foregroundColor)
      .background(configuration.isPressed ? pressedColor : backgroundColor)
      .cornerRadius(5)
  }
}

extension View {
  func niceButton(
    foregroundColor: Color = .white,
    backgroundColor: Color = .gray,
    pressedColor: Color = .accentColor
  ) -> some View {
    self.buttonStyle(
      NiceButtonStyle(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        pressedColor: pressedColor
      )
    )
  }
}



struct ContentView: View {
    @State private var title: String = ""
    @State private var selectedPriority: Priority = .medium
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]
    ) private var allTasks: FetchedResults<Task>
    
    private func saveTask(){
        do {
            let task = Task(context: viewContext)
            task.title = title
            title = ""
            task.priority = selectedPriority.rawValue
            task.dateCreated = Date()
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func styleForPriority(_ value: String) -> Color {
        let priority = Priority(rawValue: value)
        switch priority {
            case .low:
                return Color.green
            case .medium:
                return Color.orange
            case .high:
                return Color.red
            default:
                return Color.gray
        }
    }
    
    private func updateTask(_ task: Task){
        task.isFavorite.toggle()
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        offsets.forEach {index in
            let task = allTasks[index]
            viewContext.delete(task)
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Enter title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        saveTask()
                    }
                Text("Priority").italic().frame(maxWidth: .infinity, alignment: .leading).padding(.top).padding(.bottom, 4.0).padding(.leading, 8.0)
                Picker("", selection: $selectedPriority) {
                    ForEach(Priority.allCases){priority in
                        Text(priority.title).tag(priority)
                    }
                }.padding([.bottom, .trailing], 10.0).pickerStyle(.segmented)
                
                Button("Save"){
                    saveTask()
                }
                    .niceButton(
                        foregroundColor: Color.white,
                        backgroundColor: Color.accentColor,
                        pressedColor: Color.accentColor
                    )
                
                Spacer()
            }.toolbar {
                ToolbarItem(placement: .navigation){
                    Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                    })
                }
            }
            .padding()
            .navigationTitle("All Tasks")
            
            List {
                if allTasks.isEmpty {
                    Text("No tasks yet!").italic().opacity(0.4).font(.subheadline)
                }
                ForEach(allTasks){task in
                    HStack {
                        Circle().fill(styleForPriority(task.priority!)).frame(width: 5, height: 5)
                        Spacer().frame(width: 10)
                        Text(task.title ?? "")
                        Spacer()
                        Image(systemName: "trash")
                            .opacity(0.4)
                            .onTapGesture {
                                viewContext.delete(task)
                                do {try viewContext.save()} catch {print(error.localizedDescription)}
                            }
                        Image(systemName: task.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(Color.red)
                            .onTapGesture {
                                updateTask(task)
                            }
                    }
                }.onDelete(perform: deleteTask)
            }
            
        }
    }
    
    private func toggleSidebar() {
            #if os(iOS)
            #else
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
            #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        ContentView().environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}

