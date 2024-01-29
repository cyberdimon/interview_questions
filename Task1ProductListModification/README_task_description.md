# Modification of Product List

There is a platform that provides the client with marketplace capabilities for retailing their products. The platform operates in production and has a certain number of active users. Users interact with the system using a set of web and mobile applications for various operating systems. Interaction between client applications and the backend is done through RESTful API. It is necessary to implement modifications to the product catalog for the backend and API of the system based on the client's requirements.

Functional Requirements:
- Favorites
    - Provide authorized users with the ability to add products to favorites.
    - Favorite products should be displayed with a corresponding mark in the general list of all products.
    - Users should also have the ability to view the list of favorite products separately.
    - Filters and sorting in the list of favorite products should be preserved as in the general list of products.
    - The guest user cannot access the favorites functionality but should still be able to view the list of products.
- Product Details
    - It is necessary to add the ability to display more than one image for a product.
    - Existing images should remain in the current storage.
    - It has been decided to use a service based on AWS S3 for new images.

Other Customer Requirements:
- Minimize the required modifications, including from the side of client applications.
- Maintain backward compatibility of the API, as different client solution teams plan to release updates at different times.
- Ensure stability and compliance of the solution with the stated task considering future changes to the system.

### A. API Documentation

For the development teams of client applications, it is necessary to provide updated documentation of the RESTful API system. Below is an excerpt from the existing documentation on working with product lists. Describe the API change option considering all customer requirements and best practices for designing RESTful APIs. Also, consider and describe possible errors.

### Request/Response Example

```http
GET /products?category=category-1&sort=name HTTP/1.1
Host: api.market.com
Authorization: Bearer 2YotnFZFEjr1zCsicMWpAA
Accept: application/json

HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8

[
  {
    "id": 1,
    "name": "Example product 1",
    "description": "Example product 1 description",
    "image_url": "https://cdn.market.com/images/products/product_1.png",
    "category": "category-1"
  },
  {
    "id": 4,
    "name": "Example product 4",
    "description": "Example product 4 description",
    "image_url": "https://cdn.market.com/images/products/product_4.png",
    "category": "category-1"
  },
  ...
]
```

### B. Implementation  
The implementation of the Market\Product class, used to represent an object in the API response, is provided below.
```php
<?php
namespace Market;

/**
 * Represents a single product record stored in DB.
 */
class Product
{
  /*...*/

  /**
   * @var FileStorageRepository
   */
  private FileStorageRepository $storage;

  /**
   * @var string
   */
  private string $imageFileName;

  /**
   * @param FileStorageRepository $fileStorageRepository
   */
  public function __construct(FileStorageRepository $fileStorageRepository)
  {
    $this->storage = $fileStorageRepository;
  }

  /*...*/

  /**
   * Returns product image URL.
   *
   * @return string|null
   */
  public function getImageUrl(): ?string
  {
    if ($this->storage->fileExists($this->imageFileName) !== true) {
      return null;
    }

    return $this->storage->getUrl($this->imageFileName);
  }

  /**
   * Returns whether image was successfully updated or not.
   *
   * @return bool
   */
  public function updateImage(): bool
  {
    /*...*/
    try {
      if ($this->storage->fileExists($this->imageFileName) !== true) {
        $this->storage->deleteFile($this->imageFileName);
      }
      $this->storage->saveFile($this->imageFileName);
    } catch (\Exception $exception) {
      /*...*/
    }

    return false;
    /*...*/
  }
  return true;
  /*...*/
}
?>
```

The Market\FileStorageRepository class is used to work with the file system and obtain links to images in static storage.  

```php
<?php
namespace Market;

/**
 * Repository for Market's filesystem and static storage.
 */
final class FileStorageRepository
{
  /*...*/

  /**
   * Returns image URL or null.
   *
   * @param $fileName
   * @return string|null
   */
  public function getUrl($fileName): ?string
  {
    /*...*/
  }

  /**
   * Returns whether file exists or not.
   *
   * @param string $fileName
   * @return bool
   */
  public function fileExists(string $fileName): bool
  {
    /*...*/
  }

  /**
   * Deletes a file in the filesystem and throws an exception in case of errors.
   *
   * @param string $fileName
   * @return void
   */
  public function deleteFile(string $fileName): void
  {
    /*...*/
  }

  /**
   * Saves a file in the filesystem and throws an exception in case of errors.
   *
   * @param string $fileName
   * @return void
   */
  public function saveFile(string $fileName): void
  {
    /*...*/
  }
}
?>
```
A decision was made to integrate a third-party library for working with AWS services. Below are the main interfaces of the library needed for implementation.  
```php
<?php
namespace AwsS3\Client;

useuseAwsS3\AwsUrlInterface;
Exception;

/**
 *
 */
interface AwsStorageInterface
{
  /*...*/

  /**
   * Returns whether S3 connection is authorized or not.
   *
   * @return bool
   */
  public function isAuthorized(): bool;

  /*...*/

  /**
   * Returns AwsUrlInterface instance and throws an exception in case
   * connection or authorization errors.
   *
   * @param string $fileName
   * @return AwsUrlInterface
   * @throws Exception
   */
  public function getUrl(string $fileName): AwsUrlInterface;

  /*...*/
}
?>
```
```php
<?php
namespace AwsS3;

/**
 *
 */
interface AwsUrlInterface
{
  /*...*/

  /**
   * Returns string representation of the instance URL.
   *
   * @return string
   */
  public function __toString(): string;
}
/*...*/
?>
```
### C. Tests  

To maintain test coverage, it is necessary to supplement the set of Unit and API tests. Describe in a free form for which introduced or changed structural units, cases, and API responses you would prepare tests with a brief description of their purpose.