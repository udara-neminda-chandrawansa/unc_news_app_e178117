// imports
import 'package:e178117_simple_weather_news_app/login.dart';
import 'package:e178117_simple_weather_news_app/user.dart';
import 'package:flutter/material.dart';
import 'entities/news_item.dart';
import 'services/news_loader.dart';
import 'screens/filter_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/database_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(), // opens login screen first
    );
  }
}

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

// News screen class
class _NewsHomePageState extends State<NewsHomePage> {
  // vars
  late Future<NewsItems> _newsFuture;
  String _currentSortBy = 'publishedAt';
  String _currentCategory = 'general';
  String _searchTerm = 'any'; // for param 'q'
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    // load news using 'news_loader'
    _fetchNews();
  }

  // news loading method
  void _fetchNews() {
    setState(() {
      // use setState to change attributes of '_newsFuture'
      _newsFuture = NewsService.fetchNews(
        category: _currentCategory,
        searchTerm: _searchTerm,
        sortBy: _currentSortBy,
        fromDate: _fromDate,
        toDate: _toDate,
      );
    });
  }

  // filter method
  void _applyFilters(
    // vars
    String category,
    String searchTerm,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    setState(() {
      // use setState to change the states of these vars
      _currentCategory = category;
      _searchTerm = searchTerm;
      _fromDate = fromDate;
      _toDate = toDate;
    });
    _fetchNews(); // load news using changed filters
  }

  // method to show sorting options
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Sort by Relevancy'),
              onTap: () {
                setState(() {
                  // change '_currentSortBy' using setState
                  _currentSortBy = 'relevancy';
                });
                _fetchNews(); // load news using changed sorting
                // show the news screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Sort by Popularity'),
              onTap: () {
                setState(() {
                  // change '_currentSortBy' using setState
                  _currentSortBy = 'popularity';
                });
                _fetchNews(); // load news using changed sorting
                // show the news screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Sort by Date'),
              onTap: () {
                setState(() {
                  // change '_currentSortBy' using setState
                  _currentSortBy = 'publishedAt';
                });
                _fetchNews(); // load news using changed sorting
                // show the news screen
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // building the news screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News App'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.red[200],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            // view users button
            icon: Icon(Icons.verified_user_rounded),
            onPressed: () {
              // open 'UsersPage' and show registered users
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsersPage()),
              );
            },
          ),
          IconButton(
            // view filter screen button
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // open 'FilterModal' and show available filters
              // provide '_applyFilters' method as the 'onApplyFilters' method
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => FilterModal(onApplyFilters: _applyFilters),
                ),
              );
            },
          ),
          // buton to view sorting options
          IconButton(icon: Icon(Icons.sort), onPressed: _showSortOptions),
        ],
      ),
      // body of the app - this is where news items are listed
      body: FutureBuilder<NewsItems>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // if still connecting to api, show progress indicator
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              (snapshot.data!.data.isEmpty &&
                  snapshot.data!.errorMessage != null)) {
            // Show error message if available
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 60),
                  SizedBox(height: 16),
                  SelectableText(
                    snapshot.data?.errorMessage ?? 'No news available',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: _fetchNews, child: Text('Retry')),
                ],
              ),
            );
          }

          // List of News
          final news = snapshot.data!.data;
          // display it using a ListView control
          return ListView.builder(
            itemCount: news.length,
            itemBuilder: (context, index) {
              // get a news item, use its data to populate list item
              final article = news[index];
              return ListTile(
                // list items' title is news title
                title: Text(article.title),
                // list items' leading content is news image
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    article.urlToImage,
                    height: 200,
                    fit: BoxFit.cover,
                    // error handler -> show an icon of an image instead of image
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                // list items' subtitle is news source
                subtitle: Text(article.source),
                // trailing element is the published date. needs to format it before using
                trailing: Text(article.publishedAt.split('T')[0]),
                onTap: () {
                  // Implement news details view
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailsPage(newsItem: article),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// this is used to display a single news item
class NewsDetailsPage extends StatelessWidget {
  final News newsItem; // var to store a news item

  const NewsDetailsPage({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // get data from 'newsItem' and show author using appBar
      appBar: AppBar(
        title: Text("From ${newsItem.author}"),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.red[200],
        foregroundColor: Colors.white,
        // go back btn
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Go Back",
          onPressed: () {
            // go back to news list screen
            Navigator.pop(context);
          },
        ),
      ),
      // body of the screen - display other info of news item
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // show title using selectable text
            SelectableText(
              newsItem.title,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16.0), // spacing
            Center(
              // show news image centered
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  newsItem.urlToImage,
                  height: 200,
                  fit: BoxFit.cover,
                  // error handler -> show an icon of an image instead of image
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0), // spacing
            // show description using selectable text
            SelectableText(
              newsItem.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0), // spacing
            // show content using selectable text
            SelectableText(
              newsItem.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0), // spacing
            IconButton(
              // use this button to allow user to visit news url
              icon: Icon(Icons.open_in_browser),
              onPressed: () async {
                final Uri url = Uri.parse(newsItem.url);
                if (await canLaunchUrl(url)) {
                  // this is done on a seperate app (browser)
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// this is used to show list of registered users
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UserPage createState() => _UserPage();
}

class _UserPage extends State<UsersPage> {
  // text controllers for editing username, password
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  late DatabaseHandler handler; // handler for db handling
  List<User> _users = []; // list of users

  @override
  void initState() {
    super.initState();
    handler =
        DatabaseHandler(); // Initialize handler here to avoid reinitialization
    _fetchUsers(); // load all users
  }

  // method to load all users
  Future<void> _fetchUsers() async {
    // populate 'users' list, done using handler
    final users = await handler.retriveUsers();
    print('Fetched users');
    setState(() {
      // use setState to load '_users' using 'users'
      _users = users; // this updates state and notifies the UI
    });
  }

  // method to add a new user
  void _addUser() async {
    // work only if both text controllers are not empty
    if (_nameController.text.isNotEmpty && _passController.text.isNotEmpty) {
      print(
        "Adding note: Title - ${_nameController.text}, Content - ${_passController.text}",
      );
      // create a new 'User' using data from text controllers
      User newUser = User(
        name: _nameController.text,
        pass: _passController.text,
      );
      // add that 'User' to db, get return code, print it
      int result = await handler.addUser([newUser]);
      print("Number of users inserted: $result");
      // clear text controllers after adding
      _nameController.clear();
      _passController.clear();
      _fetchUsers(); // load all users
    } else {
      // if controllers empty, show this message
      print("Email or Password is empty. User not added.");
    }
  }

  // method to edit a user
  void editUser(int id) async {
    // populate text controllers using selected user's data
    _nameController.text = _users[id].name;
    _passController.text = _users[id].pass;
    // delete that user using 'deleteUser'
    deleteUser(id);
    print("I have to edit $id");
    // * This gives the user a chance to edit username, password using text controllers,
    // * and add a new user using add button
  }

  // method to delete a user
  void deleteUser(int id) async {
    // delete using '_deleteUser'
    await _deleteUser(id);
  }

  // connects with 'database_handler' to delete a user
  Future<void> _deleteUser(int index) async {
    await handler.deleteUser(_users[index].id!);
    _fetchUsers(); // refresh updated user list
  }

  // building screen to show registered users
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registered Users List"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.red[200],
        foregroundColor: Colors.white,
        leading: IconButton(
          // go back btn
          icon: const Icon(Icons.arrow_back),
          tooltip: "Go Back",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      // in body section, use a ListView to display users
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  // populate card with user data
                  child: ListTile(
                    title: Text(_users[index].name),
                    subtitle: Text(_users[index].pass),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // edit btn
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed:
                              () =>
                                  editUser(index), // Pass the user's ID to edit
                        ),
                        // delete btn
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed:
                              () => deleteUser(
                                index,
                              ), // Pass the user's ID to delete
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // text controllers are here
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.red[300],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // username (email) field
                      TextField(
                        controller: _nameController,
                        cursorColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          labelText: 'Email address',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8.0), // spacing
                      // password field
                      TextField(
                        controller: _passController,
                        cursorColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0), // spacing
                // add btn
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[500],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    onPressed: _addUser, // calls to add a new user
                    icon: const Icon(Icons.add_circle_outline_sharp),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
