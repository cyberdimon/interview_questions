<?php

namespace AwsS3\Client;

use AwsS3\AwsUrlInterface;
use Exception;

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
     * @param  string $fileName
     * @return AwsUrlInterface
     * @throws Exception
     */
    public function getUrl(string $fileName): AwsUrlInterface;
    /*...*/
}
