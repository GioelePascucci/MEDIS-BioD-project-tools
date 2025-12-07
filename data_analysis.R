# Install necessary packages if not already installed
install.packages(c("ggplot2", "reshape2", "corrplot", "dplyr"))
install.packages("sars")

# Load libraries
library(ggplot2)      # For plotting
library(readxl)       # To read Excel files
library(reshape2)     # For reshaping data
library(corrplot)     # For correlation plots
library(dplyr)        # For data manipulation
library(sars)         # Species-Area Relationship analysis
library(openxlsx)     # Export to Excel

# Load alien species data
data_alien <- read_excel("/home/gioele/Documents/Thesis/Images_plot/undefined_alien.xlsx")
data_alien <- as.data.frame(data_alien)

# Remove first column (index or ID) if present
data_alien <- data_alien[, -1]

# Filter data: only islands <= 250 km²
data_alien <- data_alien[data_alien$`area_km2` <= 250, ]

# Remove rows where distance from mainland is null
data_alien <- data_alien[data_alien$dist_mainland_km != 'null', ]
data_alien$dist_mainland_km <- as.numeric(data_alien$dist_mainland_km)

## Histogram of number of references
hist(data_alien$`N° references`)

# Create layout for multiple plots
nf <- layout(matrix(c(1,2), ncol=2))

# Set font family
par(family = "serif")

# Histogram with customized appearance
hist(data_alien$`N° references`, breaks=30, border=F, col=rgb(0.1,0.8,0.3,0.5),
     ylab="Number of islands", xlab="Number of data sources",
     main="Distribution of the number\nof data sources")

# Boxplot with customized appearance
boxplot(data_alien$`N° references`, ylab="Number of data sources",
        col=rgb(0.8,0.8,0.3,0.5), las=2)

#### Boxplot with ggplot2
ggplot(data_alien, aes(y = data_alien$`N° references`)) +
  geom_boxplot() +
  scale_fill_viridis_d() +
  labs(title = "Boxplot: Number of sources by island",
       y = "Number of references") +
  theme_minimal()

# Bubble plot: only islands <= 250 km²
data_alien <- data_alien[data_alien$dist_mainland_km != 'null', ]
data_alien$dist_mainland_km <- as.numeric(data_alien$dist_mainland_km)

par(family = "serif")

ggplot(data_alien, aes(x = area_km2, y = dist_mainland_km, size = `% su tot`)) +
  geom_point(alpha = 0.7) +
  labs(title = "Island area and distance from the mainland,\nwith percentages of undefined invasiveness",
       x = "Island area (km²)",
       y = "Distance from mainland (km)",
       size = "Percentage of taxa with \nundefined invasiveness") +
  theme_minimal() +
  theme(text = element_text(family = "liberation serif")) +
  theme(axis.text.y = element_text(vjust = 0.5, hjust = 0))  # Align y-axis labels

# Heatmap: correlation matrix of selected variables
alien_matrix <- data.matrix(data_alien[,c(4,5,6,7)], rownames.force = NA)
colnames(alien_matrix) <- c("%Unknown invasiveness", "N° of data sources","Area (km²)", "Dist. mainland (Km)")

# Calculate Spearman correlation
cor_matrix <- cor(selected_data, method = "spearman")

# Reshape correlation matrix to long format for ggplot
cor_long <- melt(cor_matrix)

# Rename variables for plotting
cor_long$Var1 <- factor(cor_long$Var1, 
                        levels = colnames(cor_matrix),
                        labels = c("% Unknown invasiveness", "N° of data sources", "Area (km²)", "Dist. mainland (Km)"))
cor_long$Var2 <- factor(cor_long$Var2, 
                        levels = colnames(cor_matrix),
                        labels = c("% Unknown invasiveness", "N° of data sources", "Area (km²)", "Dist. mainland (Km)"))

# Create heatmap
ggplot(cor_long, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0, limit = c(-1, 1),
                       name="Correlation Coefficient") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 12, hjust = 1)) +
  theme(text = element_text(family = "liberation serif")) +
  labs(title = "Heatmap of island area, distance from mainland,\npercentage of taxa with unknown invasiveness and data sources", x="", y="")

# Linear regression: % unknown invasiveness vs island area
model <- lm(data_alien$`% su tot` ~ data_alien$area_km2, data = data_alien)
summary_model <- summary(model)
r_squared <- summary_model$r.squared
p_value <- summary_model$coefficients[2, 4]

# Plot regression
ggplot(data_alien, aes(x = data_alien$area_km2, y = data_alien$`% su tot`)) +
  geom_point() +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Linear Regression: Unknown % vs Island Area",
       x = "Island area (km²)",
       y = "Percentage of taxa with unknown invasiveness") +
  annotate("text", x = 1, y = 120, 
           label = paste("R-squared:", round(r_squared, 3), "\nP-value:", format(p_value, scientific = TRUE)),
           hjust = 1.1, vjust = 1.1, size = 5, color = "black", parse = FALSE) +
  theme_bw()

# Linear regression: % unknown invasiveness vs number of references
model <- lm(data_alien$`% su tot` ~ data_alien$`N° references`, data = data_alien)
summary_model <- summary(model)
r_squared <- summary_model$r.squared
p_value <- summary_model$coefficients[2, 4]

# Plot regression
ggplot(data_alien, aes(x = data_alien$area_km2, y = data_alien$`N° references`)) +
  geom_point() +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Linear Regression: Num references vs Island Area",
       x = "Island area (km²)",
       y = "Num references") +
  annotate("text", x = 1, y = 120, 
           label = paste("R-squared:", round(r_squared, 3), "\nP-value:", format(p_value, scientific = TRUE)),
           hjust = 1.1, vjust = 1.1, size = 5, color = "black", parse = FALSE) +
  theme_bw()

# Linear regression: total alien species vs island area
model <- lm(data_alien$`total_alien` ~ data_alien$`area_km2`, data = data_alien)
summary_model <- summary(model)
r_squared <- summary_model$r.squared
p_value <- summary_model$coefficients[2, 4]

# Plot regression with log-scaled x-axis
ggplot(data_alien, aes(x = data_alien$area_km2, y = data_alien$total_alien)) +
  geom_point() +
  geom_smooth(method = "lm", color = "red") +
  scale_x_log10() +
  labs(title = "Linear Regression: Island Area vs Alien Species",
       x = "Island Area (km²)",
       y = "Number of alien species") +
  annotate("text", x = 1, y = 120, 
           label = paste("R-squared:", round(r_squared, 3), "\nP-value:", format(p_value, scientific = TRUE)),
           hjust = 1.1, vjust = 1.1, size = 5, color = "black", parse = FALSE) +
  theme_bw()

# Linear model: number of references as a function of area and distance from mainland
model <- lm(`N° references` ~ area_km2 + dist_mainland_km, data = data_alien)
anova_model <- anova(model)  # Perform ANOVA
print(anova_model)

# Scatter plot with regression lines
ggplot(data_alien, aes(x = dist_mainland_km, y = `N° references`, color = factor(area_km2))) +
  geom_point() +
  geom_smooth(method = "loess") +
  labs(title = "Number of References vs Distance from Mainland",
       x = "Distance from Mainland (km)",
       y = "Number of References",
       color = "Island Area (km²)") +
  theme_bw()

# Generalized Linear Model (GLM) with Poisson distribution
glm_model <- glm(`N° references` ~ area_km2 + dist_mainland_km, 
                 family = poisson(link = "log"), 
                 data = data_alien)
summary(glm_model)

# Transform % unknown to proportion
data_alien$proporzione_tot <- data_alien$`% su tot` / 100

# GLM with binomial distribution using proportion
glm_pct_tot <- glm(proporzione_tot ~ area_km2 + dist_mainland_km, 
                   family = binomial(link = "logit"), 
                   data = data_alien)
summary(glm_pct_tot)

### Species-Area Relationship (SAR) for alien species
alien_matrix <- data.matrix(data_alien[data_alien$total_alien>0, c(1,3,6)], rownames.force = NA)
sar_matrix <- data.matrix(cbind(alien_matrix[,3], alien_matrix[,2]))
sar_model <- sar_power(sar_matrix)
sar_model <- sar_loga(sar_matrix)

# Plot SAR
plot(sar_model, log="x",
     xlab = "Area (log scale)", 
     ylab = "Number of alien species",
     main = "Species-Area Relationship (SAR)")

# ggplot version of SAR
ggplot(data = alien_matrix, aes(x = area_km2, y = total_alien)) +
  geom_point(color = 'blue', size = 3) +
  geom_smooth(method = 'lm', color = 'red', se = FALSE) +
  scale_x_log10() +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 12, hjust = 1)) +
  theme(text = element_text(family = "liberation serif")) +
  labs(title = "Species-Area Relationship",
       x = "log(Area (km²))",
       y = "Number of alien species")

### SARs for woody-native species - Hotspot & Coldspot
woody_native <- read_excel("/home/gioele/Documents/Thesis/Images_plot/woody_native.xlsx")
woody_native <- as.data.frame(woody_native)
data_woody <- woody_native[, c(1,3,4,6)]
data_woody <- data_woody[data_woody$area_km2 != 0, ]
data_woody$area_km2 <- as.numeric(data_woody$area_km2)
data_woody <- data_woody[data_woody$area_km2 < 250, ]

# Fit multiple SAR models
fit <- sar_average(data = data_woody[,2:3], obj =  c("power","loga","koba","mmf","monod","negexpo","chapman",  "weibull3","asymp"), 
                   normaTest = "none", homoTest =  "none", neg_check = FALSE, confInt = TRUE, ciN = 50)

par(family = "Liberation Serif")

# Plot the fitted SAR curves
plot(fit, 
     allCurves = FALSE, 
     ModTitle = "Multimodel SAR of woody-native taxa", 
     confInt = TRUE, 
     ylab = "Species richness",  
     xlab = "Area (km²)")

# Add labels to points
text(x = data_woody[, 2], 
     y = data_woody[, 3], 
     labels = data_woody[, 1], 
     pos = 3, 
     cex = 0.7)

# Export confidence intervals
write.xlsx(fit$details$confInt, "hotspot_woody.xlsx")

#### Bubble plot for native-woody species
woody_endemic <- read_excel("/home/gioele/Documents/Thesis/Images_plot/woody_native.xlsx")
woody_endemic <- as.data.frame(woody_endemic)
data_endemic <- woody_endemic[,4:6]
data_endemic <- data_endemic[data_endemic$area_km2 <= 250, ]
data_endemic$dist_mainland_km <- as.numeric(data_endemic$dist_mainland_km)

# Bubble plot: island area vs distance from mainland with number of woody-native species
par(family = "serif")
ggplot(data_endemic, aes(x = area_km2, y = dist_mainland_km, size = number)) +
  geom_point(alpha = 0.7) +
  labs(title = "Island area and distance from the mainland,\nwith number of woody-native taxa",
       x = "Island log(area (km²))",
       y = "Distance from mainland (km)",
       size = "Number of woody-native\ntaxa") +
  scale_x_log10() +
  theme_bw() +
  theme(text = element_text(family = "liberation serif")) +
  theme(axis.text.y = element_text(vjust = 0.5, hjust = 0))

