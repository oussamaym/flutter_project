import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/models/book.dart';
import 'package:flutter_project/models/utilisateur.dart';
import 'package:flutter_project/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Utilisateur utilisateur = Utilisateur(nom: '', prenom: '', email: '', password: '');
  Set<Book> books = {};
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  Future<void> getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        setState(() {
          utilisateur = Utilisateur.fromMap(userData.data() as Map<String, dynamic>);
        });

        print('Authenticated User: ${utilisateur.nom}, Email: ${utilisateur.email}');
      } else {
        print('No authenticated user');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  Future<void> getBookData() async {
    try {
      QuerySnapshot bookSnapshot =
          await FirebaseFirestore.instance.collection('books').get();

      setState(() {
        books = bookSnapshot.docs.map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toSet();
      });
    } catch (e) {
      print('Error retrieving book data: $e');
    }
  }

  Future<void> addBook() async {
    try {
      Map<String, dynamic> newBook = {
        'title': titleController.text,
        'author': authorController.text,
        'price': double.parse(priceController.text),
      };

      await FirebaseFirestore.instance.collection('books').add(newBook);

      // Clear controllers after adding a book
      titleController.clear();
      authorController.clear();
      priceController.clear();

      // Refresh the book list
      await getBookData();
    } catch (e) {
      print('Error adding book: $e');
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(bookId).delete();

      // Refresh the book list
      await getBookData();
    } catch (e) {
      print('Error deleting book: $e');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  void initState() {
    getUserData();
    getBookData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour, ${utilisateur.nom} ${utilisateur.prenom}'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: (utilisateur.nom.isEmpty || books.isEmpty)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add Book Section
                    SizedBox(height: 20),
                    Text(
                      "Add New Book",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: authorController,
                      decoration: InputDecoration(
                        labelText: 'Author',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: addBook,
                      child: Text('Add Book'),
                    ),

                    // Book List Section
                    SizedBox(height: 30),
                    Text(
                      "Our Books",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 20),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: books.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var book = books.elementAt(index);
                        return Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                book.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                'By ${book.author}',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '\$${book.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                ),
                              ),
                              IconButton(
                                onPressed: () => deleteBook(book.id),
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
