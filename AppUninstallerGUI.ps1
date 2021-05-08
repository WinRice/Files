# Taken from https://github.com/farag2/Windows-10-Sophia-Script/blob/master/Sophia/PowerShell%205.1/Sophia.psm1

	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false)]
		[switch]
		$ForAllUsers
	)

	Add-Type -AssemblyName PresentationCore, PresentationFramework

	#region Variables
	# The following UWP apps will have their checkboxes unchecked
	$UncheckedAppxPackages = @(
    
        # Calculator
        "Microsoft.WindowsCalculator",
    
        # Microsoft Office
        "Microsoft.Office.Desktop.OneNote",
        "Microsoft.Office.Desktop.Word",
        "Microsoft.Office.Desktop",
        "Microsoft.Office.Desktop.Outlook",
        "Microsoft.Office.Desktop.Excel",
        "Microsoft.Office.Desktop.Access",
        "Microsoft.Office.Desktop.PowerPoint",
    
        # Microsoft Store
        "Microsoft.WindowsStore",
    
        # Photos (and Video Editor)
        "Microsoft.Windows.Photos",
        "Microsoft.Photos.MediaEngineDLC",
    
        # Xbox app group
		"Microsoft.GamingServices",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxGameOverlay"

	)

	# The following UWP apps will be excluded from the display
	$ExcludedAppxPackages = @(
        
		# HEVC Video Extensions from Device Manufacturer
		"Microsoft.HEVCVideoExtension",

		# Microsoft Store and appx dependencies
		"Microsoft.StorePurchaseApp",
        "Microsoft.DesktopAppInstaller",
    
        # Web Media Extensions
        "Microsoft.WebMediaExtensions"

        # Windows Terminal
        "Microsoft.WindowsTerminal"
	)

	#region Variables
	#region XAML Markup
	# The section defines the design of the upcoming dialog box
	[xml]$XAML = '
	<Window
		xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		Name="Window"
		MinHeight="400" MinWidth="415"
		SizeToContent="Width" WindowStartupLocation="CenterScreen"
		TextOptions.TextFormattingMode="Display" SnapsToDevicePixels="True"
		FontFamily="Candara" FontSize="16" ShowInTaskbar="True">
		<Window.Resources>
			<Style TargetType="StackPanel">
				<Setter Property="Orientation" Value="Horizontal"/>
				<Setter Property="VerticalAlignment" Value="Top"/>
			</Style>
			<Style TargetType="CheckBox">
				<Setter Property="Margin" Value="10, 13, 10, 10"/>
				<Setter Property="IsChecked" Value="True"/>
			</Style>
			<Style TargetType="TextBlock">
				<Setter Property="Margin" Value="0, 10, 10, 10"/>
			</Style>
			<Style TargetType="Button">
				<Setter Property="Margin" Value="20"/>
				<Setter Property="Padding" Value="10"/>
				<Setter Property="IsEnabled" Value="False"/>
			</Style>
			<Style TargetType="Border">
				<Setter Property="Grid.Row" Value="1"/>
				<Setter Property="CornerRadius" Value="0"/>
				<Setter Property="BorderThickness" Value="0, 1, 0, 1"/>
				<Setter Property="BorderBrush" Value="#000000"/>
			</Style>
			<Style TargetType="ScrollViewer">
				<Setter Property="HorizontalScrollBarVisibility" Value="Disabled"/>
				<Setter Property="BorderBrush" Value="#000000"/>
				<Setter Property="BorderThickness" Value="0, 1, 0, 1"/>
			</Style>
		</Window.Resources>
		<Grid>
			<Grid.RowDefinitions>
				<RowDefinition Height="Auto"/>
				<RowDefinition Height="*"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
			<Grid Grid.Row="0">
				<Grid.ColumnDefinitions>
					<ColumnDefinition Width="*"/>
					<ColumnDefinition Width="*"/>
				</Grid.ColumnDefinitions>
				<StackPanel Name="PanelSelectAll" Grid.Column="0" HorizontalAlignment="Left">
					<CheckBox Name="CheckBoxSelectAll" IsChecked="False"/>
					<TextBlock Name="TextBlockSelectAll" Margin="10,10, 0, 10"/>
				</StackPanel>
				<StackPanel Name="PanelRemoveForAll" Grid.Column="1" HorizontalAlignment="Right">
					<TextBlock Name="TextBlockRemoveForAll" Margin="10,10, 0, 10"/>
					<CheckBox Name="CheckBoxForAllUsers" IsChecked="False"/>
				</StackPanel>
			</Grid>
			<Border>
				<ScrollViewer>
					<StackPanel Name="PanelContainer" Orientation="Vertical"/>
				</ScrollViewer>
			</Border>
			<Button Name="ButtonUninstall" Grid.Row="2"/>
		</Grid>
	</Window>
	'
	#endregion XAML Markup

	$Reader = (New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $XAML)
	$Form = [Windows.Markup.XamlReader]::Load($Reader)
	$XAML.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object -Process {
		Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)
	}

	$Window.Title               = "Uninstall Apps"
	$ButtonUninstall.Content    = "Uninstall"
	$TextBlockRemoveForAll.Text = "For All Users"
	$TextBlockSelectAll.Text    = "Select All"

	$ButtonUninstall.Add_Click({ButtonUninstallClick})
	$CheckBoxForAllUsers.Add_Click({CheckBoxForAllUsersClick})
	$CheckBoxSelectAll.Add_Click({CheckBoxSelectAllClick})
	#endregion Variables

	#region Functions
	function Get-AppxBundle
	{
		[CmdletBinding()]
		param
		(
			[string[]]
			$Exclude,

			[switch]
			$AllUsers
		)

		$AppxPackages = Get-AppxPackage -PackageTypeFilter Bundle -AllUsers:$AllUsers | Where-Object -FilterScript {$_.Name -notin $ExcludedAppxPackages}
		$PackagesIds = [Windows.Management.Deployment.PackageManager, Windows.Web, ContentType = WindowsRuntime]::new().FindPackages() | Select-Object -Property DisplayName -ExpandProperty Id | Select-Object -Property Name, DisplayName

		foreach ($AppxPackage in $AppxPackages)
		{
			$PackageId = $PackagesIds | Where-Object -FilterScript {$_.Name -eq $AppxPackage.Name}

			if (-not $PackageId)
			{
				continue
			}

			[PSCustomObject]@{
				Name = $AppxPackage.Name
				PackageFullName = $AppxPackage.PackageFullName
				DisplayName = $PackageId.DisplayName
			}
		}
	}

	function Add-Control
	{
		[CmdletBinding()]
		param
		(
			[Parameter(
				Mandatory = $true,
				ValueFromPipeline = $true
			)]
			[ValidateNotNull()]
			[PSCustomObject[]]
			$Packages
		)

		process
		{
			foreach ($Package in $Packages)
			{
				$CheckBox = New-Object -TypeName System.Windows.Controls.CheckBox
				$CheckBox.Tag = $Package.PackageFullName

				$TextBlock = New-Object -TypeName System.Windows.Controls.TextBlock

				if ($Package.DisplayName)
				{
					$TextBlock.Text = $Package.DisplayName
				}
				else
				{
					$TextBlock.Text = $Package.Name
				}

				$StackPanel = New-Object -TypeName System.Windows.Controls.StackPanel
				$StackPanel.Children.Add($CheckBox) | Out-Null
				$StackPanel.Children.Add($TextBlock) | Out-Null

				$PanelContainer.Children.Add($StackPanel) | Out-Null

				if ($UncheckedAppxPackages.Contains($Package.Name))
				{
					$CheckBox.IsChecked = $false
				}
				else
				{
					$CheckBox.IsChecked = $true
					$PackagesToRemove.Add($Package.PackageFullName)
				}

				$CheckBox.Add_Click({CheckBoxClick})
			}
		}
	}

	function CheckBoxForAllUsersClick
	{
		$PanelContainer.Children.RemoveRange(0, $PanelContainer.Children.Count)
		$PackagesToRemove.Clear()
		$AppXPackages = Get-AppxBundle -Exclude $ExcludedAppxPackages -AllUsers:$CheckBoxForAllUsers.IsChecked
		$AppXPackages | Add-Control

		ButtonUninstallSetIsEnabled
	}

	function ButtonUninstallClick
	{
		$Window.Close() | Out-Null

		# If Xbox Game Bar is selected to uninstall stop its processes
		if ($PackagesToRemove -match "Microsoft.XboxGamingOverlay")
		{
			Get-Process -Name GameBar, GameBarFTServer -ErrorAction Ignore | Stop-Process -Force
		}
        Write-Host "Uninstalling selected apps..."
		$PackagesToRemove | Remove-AppxPackage -AllUsers:$CheckBoxForAllUsers.IsChecked
        Write-Host "Done."
	}

	function CheckBoxClick
	{
		$CheckBox = $_.Source

		if ($CheckBox.IsChecked)
		{
			$PackagesToRemove.Add($CheckBox.Tag) | Out-Null
		}
		else
		{
			$PackagesToRemove.Remove($CheckBox.Tag)
		}

		ButtonUninstallSetIsEnabled
	}

	function CheckBoxSelectAllClick
	{
		$CheckBox = $_.Source

		if ($CheckBox.IsChecked)
		{
			$PackagesToRemove.Clear()

			foreach ($Item in $PanelContainer.Children.Children)
			{
				if ($Item -is [System.Windows.Controls.CheckBox])
				{
					$Item.IsChecked = $true
					$PackagesToRemove.Add($Item.Tag)
				}
			}
		}
		else
		{
			$PackagesToRemove.Clear()

			foreach ($Item in $PanelContainer.Children.Children)
			{
				if ($Item -is [System.Windows.Controls.CheckBox])
				{
					$Item.IsChecked = $false
				}
			}
		}

		ButtonUninstallSetIsEnabled
	}

	function ButtonUninstallSetIsEnabled
	{
		if ($PackagesToRemove.Count -gt 0)
		{
			$ButtonUninstall.IsEnabled = $true
		}
		else
		{
			$ButtonUninstall.IsEnabled = $false
		}
	}
	#endregion Functions

	# Check "For All Users" checkbox to uninstall packages from all accounts
	if ($ForAllUsers)
	{
		$CheckBoxForAllUsers.IsChecked = $true
	}

	$PackagesToRemove = [Collections.Generic.List[string]]::new()
	$AppXPackages = Get-AppxBundle -Exclude $ExcludedAppxPackages -AllUsers:$ForAllUsers
	$AppXPackages | Add-Control

	if ($AppxPackages.Count -eq 0)
	{
		Write-Host "Nothing to display."
	}
	else
	{

		if ($PackagesToRemove.Count -gt 0)
		{
			$ButtonUninstall.IsEnabled = $true
		}
		$Form.ShowDialog() | Out-Null
	}
