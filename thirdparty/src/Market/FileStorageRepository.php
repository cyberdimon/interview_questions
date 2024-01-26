<?php
namespace Market;
/**
 * Repository for Market's filesystem and static storage.
 */
final class FileStorageRepository
{
    /**
     * Returns image URL or null.
     *
     * @param  $fileName
     * @return string|null
     */
    public function getUrl($fileName): ?string
    {
        /*...*/
    }
    /**
     * Returns whether file exists or not.
     *
     * @param  string $fileName
    5
     * @return bool
     */
    public function fileExists(string $fileName): bool
    {
        /*...*/
    }
    /**
     * Deletes a file in the filesystem and throws an exception in case of errors.
     *
     * @param  string $fileName
     * @return void
     */
    public function deleteFile(string $fileName): void
    {
        /*...*/
    }

    /**
     * Saves a file in the filesystem and throws an exception in case of errors.
     *
     * @param  string $fileName
     * @return void
     */
    public function saveFile(string $fileName): void
    {
    }
}