# python notebook_orchestation.py 

import os
import papermill as pm
import logging
from IPython.display import display, HTML
import ast

# Set up the logging configuration
logging.basicConfig(
    level=logging.INFO,  # You can change the level to DEBUG for more detailed logs
    format="%(asctime)s - %(levelname)s - %(message)s",
)

class NotebookExecutionManager:
    def __init__(self, processed_directory: str = "./processed_notebook") -> None:
        """
        Initializes the NotebookExecutionManager with a directory for processed notebooks.

        Args:
            processed_directory (str): Directory to store processed notebooks.
        """
        self.processed_directory = processed_directory

    def create_directory_if_not_exists(self, directory: str) -> None:
        """
        Ensures that the specified directory exists. If it doesn't, the directory is created.

        Parameters:
        directory (str): The path of the directory to check or create.
        """
        if not os.path.exists(directory):
            os.makedirs(directory)
            logging.info(f"Directory {directory} created.")

    def run_notebook_with_parameters(self, notebook_input_path: str, notebook_output_path: str, params: dict) -> pm.execute_notebook:
        """
        Executes a single Jupyter notebook with specified parameters and saves the result
        in the processed notebooks directory.

        Parameters:
        notebook_input_path (str): The path to the input notebook to execute.
        notebook_output_path (str): The path to save the processed notebook result.
        params (dict): The parameters to pass to the notebook.

        Returns:
        pm.execute_notebook: The executed notebook result.
        """
        # Ensure the processed notebooks directory exists
        self.create_directory_if_not_exists(self.processed_directory)

        logging.info(f"Executing {notebook_input_path} with parameters ⚡ {params} ⚡ ...")
        try:
            # Execute the notebook with the provided parameters
            execution = pm.execute_notebook(
                input_path=notebook_input_path,
                output_path=notebook_output_path,
                parameters=params
            )
            # Create a hyperlink for the result
            display(HTML(f"✅ Execution successful, check the result at the following link -> <a href='{notebook_output_path}' target='_blank'>{notebook_output_path}</a>"))
            logging.info(f"Execution of {notebook_input_path} was successful.")
        except Exception as e:
            logging.error(f"Error executing {notebook_input_path}: {e}")
            execution = None
            display(HTML(f"❌ Execution failed, check the error details and result at the following link -> <a href='{notebook_output_path}' target='_blank'>{notebook_output_path}</a>"))
        logging.info(f"Execution finished for {notebook_input_path}")
        return execution

    def extract_variable_data_from_notebook_cells(self, notebook_data: dict) -> dict:
        """
        Extracts variable data from the notebook cells and outputs the variable name,
        the operation (source), and the value associated with each variable.

        Args:
            notebook_data (dict): The content of the notebook in dictionary format.

        Returns:
            dict: A dictionary with cell execution count as keys and a dictionary of 
                  'variable_operation', 'variable_name', and 'variable_value'.
        """
        output_values = {}
        metadata = {}

        if notebook_data and isinstance(notebook_data, dict):
            for cell in notebook_data.get('cells', []):
                if cell.get('cell_type') == 'code' and 'outputs' in cell:
                    for output in cell.get('outputs', []):
                        text_plain = output.get('data', {}).get('text/plain')
                        if text_plain:
                            source = cell.get('source', '').strip()

                            if "=" in source:
                                variable_names = [var.strip() for var in source.split("=")[0].split(",")]
                                values = [text_plain.strip()]

                                if len(variable_names) > 1:
                                    if text_plain.strip().startswith('[') or text_plain.strip().startswith('('):
                                        values = text_plain.strip()[1:-1].split(',')
                                    else:
                                        values = text_plain.strip().split(',')
                                    values = [val.strip() for val in values]

                                    for i, variable in enumerate(variable_names):
                                        key = f"cell_{cell.get('execution_count')}_{i + 1}"
                                        output_values[key] = {
                                            "execution_cell_number": f"cell_{cell.get('execution_count')}",
                                            "variable_operation": source,
                                            "variable_name": variable,
                                            "variable_value": values[i] if i < len(values) else None
                                        }
                                else:
                                    output_values[f"cell_{cell.get('execution_count')}"] = {
                                        "execution_cell_number": f"cell_{cell.get('execution_count')}",
                                        "variable_operation": source,
                                        "variable_name": variable_names[0],
                                        "variable_value": values[0]
                                    }
                            else:
                                variable_name = source.split()[0] if source else None
                                output_values[f"cell_{cell.get('execution_count')}"] = {
                                    "execution_cell_number": f"cell_{cell.get('execution_count')}",
                                    "variable_operation": source,
                                    "variable_name": variable_name,
                                    "variable_value": text_plain
                                }
            metadata = notebook_data.get('metadata', {}).get('papermill', {})
            output_values['metadata'] = metadata
        return output_values

    def display_notebook_variables_and_values_extracted_from_notebook(self, extracted_variables_data_from_notebook: dict) -> dict:
        """
        Displays the extracted variables and their values from the notebook.

        Args:
            extracted_variables_data_from_notebook (dict): The extracted variables data.

        Returns:
            dict: A dictionary of variables and their values.
        """
        # Initialize an empty dictionary to store variable names and values
        variables = {}
        
        # Extract metadata from the notebook, if it exists
        metadata = extracted_variables_data_from_notebook.get('metadata', {})
        
        # Check if the input is valid and contains metadata
        if extracted_variables_data_from_notebook and isinstance(extracted_variables_data_from_notebook, dict) and metadata:
            # Log relevant information from the metadata
            logging.info(f"📓 Notebook Name: {metadata.get('input_path', 'N/A').split('/')[-1]}")
            logging.info(f"⚙️ Default Parameters: {metadata.get('default_parameters', 'N/A')}")
            logging.info(f"🔧 Parameters: {metadata.get('parameters', 'N/A')}")
            logging.info(f"🌐 Environment Variables: {metadata.get('environment_variables', 'N/A')}")
            logging.info(f"📥 Input Path: {metadata.get('input_path', 'N/A')}")
            logging.info(f"📤 Output Path: {metadata.get('output_path', 'N/A')}")
            logging.info(f"⚠️ Exception: {metadata.get('exception', 'None')}")
            logging.info("")
            
            # Iterate through each item in the extracted variables from the notebook
            for key, value in extracted_variables_data_from_notebook.items():
                # If the key is not 'metadata' and the value is a dictionary, process it
                if key != 'metadata' and isinstance(value, dict):
                    # Retrieve the variable name and its corresponding value
                    variable_name = value.get('variable_name', None)
                    variable_value = value.get('variable_value', None)
                    
                    # Try to safely parse the variable value using ast.literal_eval
                    try:
                        # Attempt to evaluate the value as a Python literal (list, dict, int, float, etc.)
                        variable_value = ast.literal_eval(str(variable_value))
                    except (ValueError, SyntaxError) as e:
                        # If parsing fails, keep the value as a string and log the error
                        logging.warning(f"⚠️ Failed to parse value for variable '{variable_name}'. Keeping it as a string. Error: {e}")
                        variable_value = str(variable_value)  # Fallback to string representation
        
                    # Log the details of the execution cell and variable
                    logging.info(f"⚓ Execution Cell Number: {value.get('execution_cell_number', 'N/A')}")
                    logging.info(f"🌀 Operation in the Cell: {value.get('variable_operation', 'N/A')}")
                    logging.info(f"♻️ Variable Cell Name: {variable_name}")
                    logging.info(f"ℹ️ Result of the Cell: {variable_value}")
                    logging.info("")
                    
                    # Add the variable to the dictionary
                    if variable_name:
                        variables[variable_name] = variable_value
        else:
            # If the input is invalid or empty, log a warning
            logging.warning("⛔ Skipping invalid or empty notebook entry.")
            logging.info("")
        
        # Return the dictionary of extracted variables
        return variables

# Step 1: Create an instance of the NotebookExecutionManager class
# The 'processed_directory' argument specifies where processed notebooks will be saved
processor = NotebookExecutionManager(processed_directory="./processed_notebook")

# Step 2: Define the notebooks with parameters
# Each tuple contains:
# - The input notebook path (e.g., "1_Add.ipynb")
# - The output notebook path where the executed notebook will be saved (e.g., "./processed_notebook/add_executed.ipynb")
# - A dictionary of parameters that will be passed to the notebook during execution (e.g., {"params": [10, 5, 7]})
notebooks_with_parameters = [
    ("./1_Add.ipynb", f"{processor.processed_directory}/add_executed.ipynb", {"params": [10, 5, 7]}),
    ("./4_Divide.ipynb", f"{processor.processed_directory}/divide_executed.ipynb", {"x": 20, "y": 0}),
    ("./2_Subtract.ipynb", f"{processor.processed_directory}/subtract_executed.ipynb", {"x": 10, "y": 3}),
    ("./3_Multiply.ipynb", f"{processor.processed_directory}/multiply_executed.ipynb", {"inject_values": {'x': [2, 3], 'y': [4, 5]}}),
]

# Step 3: Initialize an empty list to store the execution results of each notebook
notebook_execution_results = []

# Step 4: Loop through each notebook, execute it with the specified parameters, and store the result
# - For each notebook, 'input_path' is the path to the input notebook
# - 'output_path' is the location where the executed notebook will be saved
# - 'params' is the dictionary of parameters that will be used during execution
for input_path, output_path, params in notebooks_with_parameters:
    # Call the run_notebook_with_parameters method to execute the notebook
    notebook_results = processor.run_notebook_with_parameters(input_path, output_path, params)
    
    # Append the result of each notebook execution to the results list
    notebook_execution_results.append(notebook_results)

# Step 5: Iterate over each notebook result and extract variable data
# For each executed notebook, if the execution was successful (not None),
# we extract the variable data and display it
notebook_variables = list()

for notebook_result in notebook_execution_results:
    if notebook_result:
        # Extract variable data from the notebook's cells
        extracted_data = processor.extract_variable_data_from_notebook_cells(notebook_result)
        
        # Display the extracted data (variable names, values, etc.)
        notebook_variables.append(processor.display_notebook_variables_and_values_extracted_from_notebook(extracted_data))

notebook_variables