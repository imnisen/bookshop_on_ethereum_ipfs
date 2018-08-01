# Project Meepo -- A ethereum based book shop

This is a prototype of "ethereum+ipfs" based bookshop.

Name cames from [Meepo](http://www.dota2.com.cn/hero/meepo/).

## Workflow
In general, when Alice want to buy a book from Bob:

1. Both of them need to set their key pair and get some fake money.
   
   They generate rsa key pair, register public key to ethereum and keep private key their own.

2. Bob publish a book he wants to sell.
   
   The Book will be encrypt by a random aes key, after that, push the encrypted book to ipfs, 
   then use Bob's public key to encrypt aes key and publish it to ethereum.

3. Alice make an order to buy Bob's book.
   
   Just create an order info in ethereum.

4. Bob approve this order with his private key

   First get the encrypted book from ipfs , then use Bob's private key to decrypted aes key,
   then we can decrypt the book.
   After that, generate a new aes key and encrypt book with it. Then encrypt the new aes key with Alice public key.
   And publish new encrypted book to ipfs and necessary data to ethereum.   

5. Alice download the book
   
   First get the encrypted book from ipfs , then use Alice's private key to decrypted aes key,
   then we use aes key to decrypt to get the origin book.

  

## Consideration

Here we use store file in IPFS and store operation data in smart contract since contract now not proper to store big file.

In order to keep file private , we use RSA encryption to make sure we can control who can see it.

On the other hand, as RSA is slow and costly, we use AES instead to encrypt and decrypt file, and use RSA to encrypt the AES key.

## TODO-LIST
The code and UI is a little messy now, at least needs following work:

- [ ] Add test contract case
- [ ] Make UI smoothly
- [ ] Add error handlers
- [ ] Change contract data type to use less
- [ ] Add security checkers
- [ ] Refactor messy js code



