//
//  BookSearchViewController.swift
//  Consulta Persistente ISBN
//
//  Created by Francisco Betancourt on 13/03/2016.
//  Copyright © 2016 Francisco Betancourt. All rights reserved.
//

import UIKit
import CoreData

class BookSearchViewController: UIViewController {

   @IBOutlet weak var isbnTextField : UITextField!

   private let baseurl = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"

   var book : Book!
   var bookList : BookListTableViewController!
   var context: NSManagedObjectContext!

   override func viewDidLoad() {

      super.viewDidLoad()

      context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
   }

   override func didReceiveMemoryWarning() {

      super.didReceiveMemoryWarning()
   }

   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

      isbnTextField.text = nil
      (segue.destinationViewController as! BookDetailsViewController).book = self.book
   }

   func searchBook (isbn: String, completionHandler: (book: Book) -> Void) {

      NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: baseurl + isbn)!, completionHandler: {(data, response, error) in

         if error != nil {

            dispatch_async(dispatch_get_main_queue(), {

               ProgressView.sharedInstance.hideProgressView()
            })

            self.showAlertDialog("Error", message: error!.localizedDescription)

         } else {

            var book = Book(isbnCode: isbn, title: "Título No Definido", authors: [ "Autor No Definido" ], cover: UIImage())

            do {

               if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String : AnyObject] {

                  if let bookJson = json["ISBN:" + isbn] as? [String : AnyObject] {

                     if let authors = bookJson["authors"] as? [AnyObject] {

                        book.authors.removeAll()

                        for author in authors {

                           book.authors.append(author["name"] as! String)
                        }
                     }

                     if let title = bookJson["title"] as? String {

                        book.title = title
                     }

                     if let cover = bookJson["cover"]?["large"] as? String {

                        if let coverImg = UIImage(data: NSData(contentsOfURL: NSURL(string: cover)!)!) {

                           book.cover = coverImg
                        }
                     }

                     completionHandler(book: book)

                  } else {

                     dispatch_async(dispatch_get_main_queue(), {

                        self.isbnTextField.text = nil
                        ProgressView.sharedInstance.hideProgressView()
                     })

                     self.showAlertDialog("Error", message: "El Libro con ISBN \(isbn) no Existe!")
                  }
               }

            } catch _ {

               dispatch_async(dispatch_get_main_queue(), {

                  ProgressView.sharedInstance.hideProgressView()
               })

               self.showAlertDialog("Error", message: "Respuesta invalida del servidor openlibrary.org")
            }
         }

      }).resume()
   }

   func showAlertDialog (title: String, message: String) {

      let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))

      dispatch_async(dispatch_get_main_queue(), {

         self.presentViewController(alert, animated: true, completion: nil)
      })
   }

   func findBookInTable (isbn: String) -> Book! {

      var bookFound : Book!

      for book in bookList.books {

         if isbn == book.isbnCode {

            bookFound = book
            break
         }
      }

      return bookFound
   }

   @IBAction func search (sender: UITextField) {

      sender.resignFirstResponder()

      if let isbn = sender.text where !isbn.isEmpty {

         if let book = findBookInTable(isbn) {

            self.book = book
            performSegueWithIdentifier("bookSegue", sender: sender)

         } else {

            ProgressView.sharedInstance.showProgressView(view)

            searchBook(isbn) { bookFound in

               self.book = bookFound
               self.bookList.books.append(bookFound)

               let bookEntity = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: self.context!)

               bookEntity.setValue(bookFound.isbnCode, forKey: "isbn")
               bookEntity.setValue(bookFound.title, forKey: "title")
               bookEntity.setValue(bookFound.authors, forKey: "author")
               bookEntity.setValue(UIImageJPEGRepresentation(bookFound.cover, 1.0), forKey: "cover")

               do {

                  try self.context.save()
                  
               } catch {

                  print("\(__FUNCTION__): Unable to save context!")
               }

               dispatch_async(dispatch_get_main_queue(), {

                  ProgressView.sharedInstance.hideProgressView()
                  self.performSegueWithIdentifier("bookSegue", sender: sender)
               })
            }
         }
      }
   }
}