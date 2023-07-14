# gcloud-recon

```
               .__                   .___                                            
   ____   ____ |  |   ____  __ __  __| _/        _______   ____   ____  ____   ____  
  / ___\_/ ___\|  |  /  _ \|  |  \/ __ |  ______ \_  __ \_/ __ \_/ ___\/  _ \ /    \ 
 / /_/  >  \___|  |_(  <_> )  |  / /_/ | /_____/  |  | \/\  ___/\  \__(  <_> )   |  \
 \___  / \___  >____/\____/|____/\____ |          |__|    \___  >\___  >____/|___|  /
/_____/      \/                       \/                      \/     \/           \/ 
```

## Description
**gcloud-recon** is a script that performs reconnaissance on Google Cloud Platform (GCP) resources using the `gcloud` command-line tool. It retrieves information about Compute Engine, BigQuery, Container, and Cluster resources for a given list of GCP projects.

## Usage
1. **Install the required dependencies:**
   - Make sure you have the `gcloud` command-line tool installed and authenticated properly.
   - Install any additional dependencies mentioned in the project's documentation.

2. **Clone the repository:**
   ```
   git clone https://github.com/your-username/gcloud-recon.git
   cd gcloud-recon
   ```
3. **Run the script:**
Provide the filename as an argument when running the script to specify the list of GCP projects.

   ```./recon.sh project_list.txt```
4. **View the output:**
   - The script will display information about Compute Engine, BigQuery, Container, and Cluster resources for each project listed in the input file.

## Contributing
Contributions are welcome! If you have any suggestions, improvements, or bug fixes, feel free to open an issue or submit a pull request.

## License
This project is licensed under the MIT License.
