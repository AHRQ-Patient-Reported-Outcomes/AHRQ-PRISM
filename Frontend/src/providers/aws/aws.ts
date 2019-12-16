import { Injectable } from '@angular/core';
import AWS from 'aws-sdk'

export interface awsCredentials {
  accessKeyId: string;
  secretAccessKey: string;
  sessionToken: string;
  [ key: string ]: any;
}

@Injectable()
export class AwsProvider {

  public awsInstance: any;

  constructor() {
    this.awsInstance = AWS;
    this.awsInstance.config.region = 'us-east-1';
  }

  public setCredentials(credentials: awsCredentials) : void {
    const { accessKeyId,  secretAccessKey, sessionToken } = credentials;

    this.awsInstance.config.credentials = new AWS.Credentials(
      accessKeyId,
      secretAccessKey,
      sessionToken
    );
  }

  private apiGatewayClient: any;
  public getApiGatewayClient() {
    if (!this.awsInstance.config.credentials) { throw 'Need to add credentials first'}

    if (!this.apiGatewayClient) {
      this.apiGatewayClient = new this.awsInstance.ApiGatewayV2()
    }
  }
}
