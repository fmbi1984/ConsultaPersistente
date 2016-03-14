//
//  BookListTableViewController.swift
//  Consulta Persistente ISBN
//
//  Created by Francisco Betancourt on 13/03/2016.
//  Copyright © 2016 Francisco Betancourt. All rights reserved.
//

import UIKit
import CoreData

class BookListTableViewController: UITableViewController {

   var books = [Book]()
   var context: NSManagedObjectContext!

   override func viewDidLoad() {

      super.viewDidLoad()

      context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
      fetchBooksFromStorage()
   }

   override func didReceiveMemoryWarning() {

      super.didReceiveMemoryWarning()
   }

   override func viewWillAppear(animated: Bool) {

      tableView.reloadData()
   }

   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

      return 1
   }

   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

      return books.count
   }

   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

      let cell = tableView.dequeueReusableCellWithIdentifier("BookCell", forIndexPath: indexPath)

      cell.textLabel?.text = books[indexPath.row].title

      return cell
   }

   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

      if (sender is UITableViewCell) {

         (segue.destinationViewController as! BookDetailsViewController).book = books[tableView.indexPathForSelectedRow!.row]
      }

      if (sender is UIBarButtonItem) {

         (segue.destinationViewController as! BookSearchViewController).bookList = self
      }
   }

   func fetchBooksFromStorage () {

      let bookEntity = NSEntityDescription.entityForName("Book", inManagedObjectContext: context!)

      let fetchAllBooks = bookEntity?.managedObjectModel.fetchRequestTemplateForName("AllBooks")

      do {

         let fetchedBooks = try context.executeFetchRequest(fetchAllBooks!)

         for fetchedBook in fetchedBooks {

            let isbn = fetchedBook.valueForKey("isbn") as! String
            let title = fetchedBook.valueForKey("title") as! String
            let author = fetchedBook.valueForKey("author") as! [String]
            let cover = fetchedBook.valueForKey("cover")

            var book = Book(isbnCode: isbn, title: title, authors: author, cover: UIImage())

            if cover != nil {

               book.cover = UIImage(data: cover as! NSData)!
            }

            books.append(book)
         }

      } catch {

         print("\(__FUNCTION__): Unable to execute fetch request!")
      }
   }
}