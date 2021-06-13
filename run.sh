#!/bin/bash

export app_ip=$(terraform output PublicIPForLB)
echo $app_ip