using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Medicamento")]
public class Medicamento
{
    [Key]
    public int IdMedicamento { get; set; }
    [Required, MaxLength(200)]
    public string Nombre { get; set; } = string.Empty;
    [MaxLength(100)]
    public string? Presentacion { get; set; }
    [MaxLength(50)]
    public string? Concentracion { get; set; }
    [MaxLength(100)]
    public string? Laboratorio { get; set; }
    [Column(TypeName = "decimal(10,2)")]
    public decimal Precio { get; set; }
    public int Stock { get; set; } = 0;
    public bool Activo { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;
}
